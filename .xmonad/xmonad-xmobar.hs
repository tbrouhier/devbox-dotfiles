--
-- xmonad config file.
--

import           Data.Monoid
import           System.Exit
import           XMonad
import qualified XMonad.Actions.GridSelect as GridSelect

import qualified Data.Map                     as M
import           Graphics.X11.ExtraTypes.XF86
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.SetWMName
import           XMonad.Layout.ZoomRow
import           XMonad.Util.SpawnOnce
import qualified XMonad.StackSet              as W

-- Some doc
-- .|. is xmonad specific : it is a bitwise "or"


-- Key bindings.
-- myKeys return a Map (associative list)
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modm .|. shiftMask, xK_t), spawn $ XMonad.terminal conf)
    , ((modm, xK_t), spawn $ XMonad.terminal conf)

    -- launch README
    , ((0, xK_F1 ), spawn "chromium file:///home/vagrant/.local/share/doc/devbox.html")

    -- launch dmenu
    , ((modm, xK_p), GridSelect.spawnSelected GridSelect.defaultGSConfig [ "eclipse", "chromium", "firefox" ])

    -- launch editor
    -- , ((modm .|. shiftMask, xK_comma ), spawn "emacsclient -c")
    , ((modm .|. shiftMask, xK_comma ), spawn "vim")

    -- resize wallpaper
    , ((modm .|. shiftMask, xK_i), spawn "feh --bg-scale ${HOME}/.wallpaper.jpg" )

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Expand the master area
    , ((modm,               xK_m     ), sendMessage zoomIn)
    -- Move focus to the master window
    --, ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage zoomOut)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]


myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = Mirror zoomRow ||| Mirror tiled ||| zoomRow ||| Full ||| tiled
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
myStartupHook = do
  setWMName "LG3D"
  spawnOnce "stalonetray"

azertyKeys conf@(XConfig {modMask = modm}) = M.fromList $
    [((modm, xK_semicolon), sendMessage (IncMasterN (-1)))]
    ++
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (workspaces conf) [0x26,0xe9,0x22,0x27,0x28,0xa7,0xe8,0x21,0xe7,0xe0],
          (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

main =
  xmonad =<< statusBar "xmobar" myPP toggleStrutsKey myConfig

  where
    toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

    myPP = xmobarPP
      { ppCurrent = xmobarColor "orange" "" . wrap "[" "]"
      , ppTitle = xmobarColor "#2CE3FF" "" . shorten 50
      , ppLayout = const "" -- to disable the layout info on xmobar
      }

    myConfig  = defaultConfig
      { terminal           = "urxvt"
      , focusFollowsMouse  = False
      , borderWidth        = 1
      , modMask            = mod4Mask
      , workspaces         = ["1","2","3","4","5","6","7","8","9"]
      , normalBorderColor  = "#333333"
      , focusedBorderColor = "#AFAF87"
      , keys               = \c -> azertyKeys c `M.union` myKeys c
      , mouseBindings      = myMouseBindings
      , layoutHook         = avoidStruts $ myLayout
      , startupHook        = myStartupHook
      }
