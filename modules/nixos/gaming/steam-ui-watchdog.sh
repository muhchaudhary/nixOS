# steam-ui-watchdog GAMESCOPE_PID: recovers a hung Big Picture UI for as long
# as Gaming Mode's gamescope runs (started by gaming-mode, see gaming-mode.nix).
#
# The hang: quitting a game right after it starts rendering sometimes leaves
# the steamwebhelper renderer that hosts Steam's UI pages spinning in native
# code inside Steam's CEF (libcef.so), leaking ~30 MB/s, with the screen frozen.
# Independent of the game, the Steam branch, GPU web rendering, Decky, game
# recording and our gamescope/overlay patches. SIGKILLing that renderer (it
# ignores SIGTERM) makes Steam reload its UI within a few seconds.
#
# Detection, every 5 s: SharedJSContext (in that renderer) not answering
# Runtime.evaluate on Steam's CEF debug port 3 times in a row (~15-30 s); the
# port needs ~/.local/share/Steam/.cef-enable-remote-debugging (gaming-mode
# creates it), without it only the memory ceilings apply. Or the renderer past
# 3 GB (it normally stays under ~700 MB): killed at once.
#
# The browser process (`steamwebhelper -nocrashdialog`, the renderers' parent)
# can leak too (seen at 20 GB alongside a hung renderer; normally ~600 MB):
# past 3 GB it's SIGKILLed as well, and Steam starts a new one.

gamescope_pid=$1
state="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/gaming-mode"
max_rss_kb=$((3 * 1024 * 1024))

# 0 answers, 1 doesn't, 2 can't tell (no debug port, or Steam (re)starting).
steam_ui_responds() {
  local ws
  ws=$(curl -s --max-time 2 http://127.0.0.1:8080/json 2>/dev/null |
    jq -r 'first(.[] | select(.type == "page" and .title == "SharedJSContext") | .webSocketDebuggerUrl) // empty' 2>/dev/null) || ws=""
  [ -n "$ws" ] || return 2
  timeout 5 websocat -n1 -B 1048576 "$ws" \
    <<<'{"id":1,"method":"Runtime.evaluate","params":{"expression":"1"}}' 2>/dev/null |
    grep -q '"id":1' || return 1
}

# The renderers are CEF zygote forks: zygote-typed steamwebhelpers whose parent
# is a zygote too. Prints "pid rss_kb" of the largest (Big Picture's is the
# largest normally, and the hung one balloons).
steam_ui_renderer() {
  ps -u "$(id -u)" -o pid=,ppid=,rss=,args= | awk '
    /steamwebhelper/ && /--type=zygote/ { z[$1] = 1; pp[$1] = $2; rss[$1] = $3 }
    END { for (p in z) if (pp[p] in z && rss[p] > best) { best = rss[p]; pid = p }
          if (pid) print pid, best }'
}

# The browser process: the steamwebhelper that isn't a typed child (its
# children carry --type=..., incl. /proc/self/exe utility processes). Prints
# "pid rss_kb" of the largest.
steam_ui_browser() {
  ps -u "$(id -u)" -o pid=,rss=,args= | awk '
    /steamwebhelper/ && !/--type=/ && $2 > best { best = $2; pid = $1 }
    END { if (pid) print pid, best }'
}

recover() {
  local pid rss
  read -r pid rss < <(steam_ui_renderer) || return 0
  echo "steam-ui-watchdog: Steam's UI hung ($1), killing its renderer $pid ($((rss / 1024)) MB)"
  kill -9 "$pid" 2>/dev/null || true
  # Give Steam time to reload its UI before probing again.
  sleep 30
}

fails=0
while kill -0 "$gamescope_pid" 2>/dev/null; do
  sleep 5
  # Steam shutting down on purpose, or Gaming Mode relaunching.
  if [ -f "$state/leaving" ] || [ -f "$state/restarting" ]; then
    fails=0
    continue
  fi

  bpid="" brss=0
  read -r bpid brss < <(steam_ui_browser) || true
  if [ "${brss:-0}" -gt "$max_rss_kb" ]; then
    echo "steam-ui-watchdog: Steam's UI browser process at $((brss / 1024)) MB, killing $bpid"
    kill -9 "$bpid" 2>/dev/null || true
    sleep 30
    fails=0
    continue
  fi

  rss=0
  read -r _ rss < <(steam_ui_renderer) || true
  if [ "${rss:-0}" -gt "$max_rss_kb" ]; then
    recover "renderer at $((rss / 1024)) MB"
    fails=0
    continue
  fi

  rc=0
  steam_ui_responds || rc=$?
  if [ "$rc" = 1 ]; then
    fails=$((fails + 1))
    if [ "$fails" -ge 3 ]; then
      recover "not responding"
      fails=0
    fi
  else
    fails=0
  fi
done
