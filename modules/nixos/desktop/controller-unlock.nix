# Unlock hyprlock from a controller (the desktop's GameSir, from the couch):
#
# - `controller-unlock` (root service) takes over every gamepad, only while
#   hyprlock or `set-lock-pin` runs (EVIOCGRAB, so nothing else sees the
#   presses then), and types them on a virtual keyboard:
#     A 1, B 2, X 3, Y 4, d-pad up/down/left/right 5/6/7/8, LB 9, RB 0,
#     Start = Enter, Select (View) = Backspace.
# - hyprlock's PAM stack (only hyprlock: not sudo, not the console login)
#   accepts that PIN as well as the password; a wrong PIN falls through to
#   the password check, so the keyboard works as before.
# - `set-lock-pin` sets it, pressed on the controller: an scrypt hash in
#   ~/.local/state/controller-unlock/pin (0600). Never in this repo: a short
#   PIN's hash is cracked in seconds. No file, no PIN unlock.
#
# Weaker than the password by design (a 6+ button PIN over 10 buttons);
# pam_unix's ~2 s delay after each failure is the brute-force brake.
{
  config,
  lib,
  pkgs,
  ...
}: let
  pinFile = ".local/state/controller-unlock/pin";

  daemon =
    pkgs.writers.writePython3Bin "controller-unlock" {
      libraries = [pkgs.python3Packages.evdev];
      flakeIgnore = ["E501"];
    } ''
      import os
      import select
      import time

      import evdev
      from evdev import ecodes as e

      # Processes that want the controller as a PIN pad.
      TRIGGERS = {"hyprlock", "set-lock-pin"}

      BUTTONS = {
          e.BTN_SOUTH: e.KEY_1,  # A
          e.BTN_EAST: e.KEY_2,  # B
          e.BTN_NORTH: e.KEY_3,  # X (xpad's BTN_X)
          e.BTN_WEST: e.KEY_4,  # Y (xpad's BTN_Y)
          e.BTN_DPAD_UP: e.KEY_5,
          e.BTN_DPAD_DOWN: e.KEY_6,
          e.BTN_DPAD_LEFT: e.KEY_7,
          e.BTN_DPAD_RIGHT: e.KEY_8,
          e.BTN_TL: e.KEY_9,
          e.BTN_TR: e.KEY_0,
          e.BTN_START: e.KEY_ENTER,
          e.BTN_SELECT: e.KEY_BACKSPACE,
      }
      # Most pads report the d-pad as a hat instead.
      HAT = {
          (e.ABS_HAT0Y, -1): e.KEY_5,
          (e.ABS_HAT0Y, 1): e.KEY_6,
          (e.ABS_HAT0X, -1): e.KEY_7,
          (e.ABS_HAT0X, 1): e.KEY_8,
      }
      NAME = "controller-unlock keypad"


      # hyprlock and set-lock-pin run in the Hyprland session, on greetd's VT1.
      # With another VT in front (Gaming Mode's session on tty2, a console),
      # the controller belongs to it: a hyprlock left behind in the background
      # (hypridle locks it on suspend) mustn't take it away.
      def foreground_vt():
          try:
              with open("/sys/class/tty/tty0/active") as f:
                  return f.read().strip()
          except OSError:
              return "tty1"


      def wanted():
          if foreground_vt() != "tty1":
              return False
          for pid in os.listdir("/proc"):
              if pid.isdigit():
                  try:
                      with open(f"/proc/{pid}/comm") as f:
                          if f.read().strip() in TRIGGERS:
                              return True
                  except OSError:
                      pass
          return False


      def gamepads():
          for path in evdev.list_devices():
              try:
                  dev = evdev.InputDevice(path)
              except OSError:
                  continue
              if dev.name != NAME and e.BTN_SOUTH in dev.capabilities().get(e.EV_KEY, []):
                  yield dev
              else:
                  dev.close()


      def tap(ui, key):
          ui.write(e.EV_KEY, key, 1)
          ui.syn()
          ui.write(e.EV_KEY, key, 0)
          ui.syn()


      def main():
          ui = evdev.UInput({e.EV_KEY: sorted(set(BUTTONS.values()))}, name=NAME)
          grabbed = {}  # path -> InputDevice
          while True:
              if not wanted():
                  for dev in grabbed.values():
                      try:
                          dev.ungrab()
                      except OSError:
                          pass
                      dev.close()
                  grabbed.clear()
                  time.sleep(0.5)
                  continue

              # Pick up pads as they connect (a wireless one wakes after the lock).
              for dev in gamepads():
                  if dev.path in grabbed:
                      dev.close()
                      continue
                  try:
                      dev.grab()
                      grabbed[dev.path] = dev
                  except OSError:
                      dev.close()

              ready, _, _ = select.select(list(grabbed.values()), [], [], 0.5)
              for dev in ready:
                  try:
                      events = list(dev.read())
                  except OSError:  # unplugged
                      grabbed.pop(dev.path, None)
                      dev.close()
                      continue
                  for ev in events:
                      if ev.type == e.EV_KEY and ev.value == 1 and ev.code in BUTTONS:
                          tap(ui, BUTTONS[ev.code])
                      elif ev.type == e.EV_ABS and (ev.code, ev.value) in HAT:
                          tap(ui, HAT[(ev.code, ev.value)])


      main()
    '';

  # pam_exec (expose_authtok): the typed secret on stdin, NUL-terminated.
  # Runs as the locking user; succeeds only on a PIN match.
  checkPin =
    pkgs.writers.writePython3 "controller-unlock-check" {
      flakeIgnore = ["E501"];
    } ''
      import hashlib
      import hmac
      import os
      import pwd
      import stat
      import sys

      try:
          user = pwd.getpwnam(os.environ["PAM_USER"])
          path = os.path.join(user.pw_dir, "${pinFile}")
          st = os.stat(path)
          # Only a file the user owns that nobody else can touch.
          if st.st_uid != user.pw_uid or st.st_mode & (stat.S_IRWXG | stat.S_IRWXO):
              sys.exit(1)
          with open(path) as f:
              algo, n, r, p, salt, digest = f.read().strip().split("$")
          secret = sys.stdin.buffer.read().rstrip(b"\0")
          if algo != "scrypt" or not secret:
              sys.exit(1)
          got = hashlib.scrypt(secret, salt=bytes.fromhex(salt), n=int(n), r=int(r), p=int(p), maxmem=64 * 1024 * 1024)
          sys.exit(0 if hmac.compare_digest(got.hex(), digest) else 1)
      except Exception:
          sys.exit(1)
    '';

  setPin =
    pkgs.writers.writePython3Bin "set-lock-pin" {
      flakeIgnore = ["E501"];
    } ''
      import getpass
      import hashlib
      import os
      import sys

      N, R, P = 2**14, 8, 1
      path = os.path.expanduser("~/${pinFile}")

      if sys.argv[1:] == ["--remove"]:
          try:
              os.remove(path)
              print("Controller PIN removed: hyprlock takes the password only.")
          except FileNotFoundError:
              print("No controller PIN set.")
          sys.exit(0)

      print("Controller buttons type the PIN while this runs:")
      print("  A 1  B 2  X 3  Y 4  d-pad up 5  down 6  left 7  right 8  LB 9  RB 0")
      print("  Start = done, Select = delete.  (--remove to drop the PIN.)")
      pin = getpass.getpass("New PIN (at least 6 presses): ")
      if len(pin) < 6 or not pin.isdigit():
          sys.exit("Use at least 6 controller presses.")
      if getpass.getpass("Again: ") != pin:
          sys.exit("They don't match; nothing changed.")

      salt = os.urandom(16)
      digest = hashlib.scrypt(pin.encode(), salt=salt, n=N, r=R, p=P, maxmem=64 * 1024 * 1024)
      os.makedirs(os.path.dirname(path), mode=0o700, exist_ok=True)
      fd = os.open(path + ".new", os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
      with os.fdopen(fd, "w") as f:
          f.write("$".join(["scrypt", str(N), str(R), str(P), salt.hex(), digest.hex()]) + "\n")
      os.replace(path + ".new", path)
      print("Controller PIN set: it unlocks hyprlock (only), alongside your password.")
    '';
in {
  environment.systemPackages = [setPin];

  systemd.services.controller-unlock = {
    description = "Controller as a PIN pad while hyprlock runs";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = lib.getExe daemon;
      Restart = "always";
      RestartSec = 2;
      DevicePolicy = "closed";
      DeviceAllow = ["/dev/uinput rw" "char-input rw"];
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateNetwork = true;
      NoNewPrivileges = true;
    };
  };

  # Before pam_unix (13100): unix-early has prompted by then, so the secret is
  # already PAM_AUTHTOK; a match is `sufficient`, anything else falls through.
  security.pam.services.hyprlock.rules.auth.controller-pin = {
    order = config.security.pam.services.hyprlock.rules.auth.unix.order - 50;
    control = "sufficient";
    modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
    args = ["expose_authtok" "quiet" "${checkPin}"];
  };
}
