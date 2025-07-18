{-
  My XMonad configuration.

  Here be monads, hapless wanderers beware!

TODO
---------
-}

import           Data.IORef                     ( IORef
                                                , modifyIORef'
                                                , newIORef
                                                , readIORef
                                                )
import           Data.Map                       ( Map )
import qualified Data.Map                      as M
import           System.Exit
import           System.IO
{- XMonad core
-------------------------------------------------}
import           XMonad
import qualified XMonad.StackSet               as W

{- Actions
-------------------------------------------------}
import           XMonad.Actions.CopyWindow
import           XMonad.Actions.PhysicalScreens
import           XMonad.Actions.UpdatePointer   ( updatePointer )
{- Hooks
-------------------------------------------------}
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.Place
import           XMonad.Hooks.SetWMName
import           XMonad.Hooks.StatusBar         ( StatusBarConfig
                                                , statusBarProp
                                                , withSB
                                                )
import           XMonad.Hooks.StatusBar.PP      ( xmobarPP )
{- Layout related stuff
-------------------------------------------------}
import           XMonad.Layout.BinarySpacePartition
import           XMonad.Layout.Gaps
import           XMonad.Layout.NoBorders
import           XMonad.Layout.ResizableTile
import           XMonad.Layout.Spacing
import           XMonad.Layout.SubLayouts       ( GroupMsg(..)
                                                , onGroup
                                                , pullGroup
                                                , subTabbed
                                                )
import           XMonad.Layout.Tabbed
import           XMonad.Layout.ToggleLayouts
import           XMonad.Layout.WindowNavigation ( windowNavigation )

{- Utils
-------------------------------------------------}
import           XMonad.Util.NamedScratchpad
import           XMonad.Util.Run

myModMask :: KeyMask
myModMask = mod4Mask

myTerminal :: String
myTerminal = "alacritty"

myScratchpads :: [NamedScratchpad]
myScratchpads =
  [ NS "mupad" "spotify" (className =? "Spotify") doFullFloat
  , NS "termpad"
       (termArgs "termpad" "tmux new-session -A -s termpad")
       (title =? "termpad")
       doFullFloat
  , NS "empad"
       "~/scripts/emacs/open-graphical server"
       (title =? "server")
       doCenterFloat
  , NS "notepad" "logseq --disable-gpu" (className =? "Logseq") doCenterFloat
  , NS "chatpad"
       (termArgs "chatpad" "~/.local/bin/wchat")
       (title =? "chatpad")
       doFullFloat
  ]
  where termArgs tit cmd = unwords [myTerminal, "-t", tit, "-e", cmd]

-- | Stuff that will run every time XMonad is either started or restarted.
myStartupHook :: X ()
myStartupHook = do
  safeSpawn "pkill" ["trayer"]
  safeSpawn "pkill" ["picom"]
  dir <- asks (cfgDir . directories)
  safeSpawn (dir ++ "/xmobar-trayer.sh") []
  setWMName "LG3D"

myManageHook :: ManageHook
myManageHook =
  composeOne [isFullscreen -?> doFullFloat, isDialog -?> doCenterFloat]
    <+> composeAll
          [ className =? "Gimp" --> doFloat
          , className =? "Gnome-panel" --> doIgnore
          , className =? "Gtkdialog" --> doFloat
          , className =? "Pinentry" --> doFloat
          , className =? "gcr-prompter" --> doCenterFloat
          , className =? "Spotify" --> doCenterFloat
          , title =? "xmessage" --> doCenterFloat
          ]
    <+> namedScratchpadManageHook myScratchpads
    <+> manageDocks

myWorkspaces :: [String]
myWorkspaces = ws
 where
  ws :: [String]
  ws = zipWith makeLabel [1 .. 10] icons

  makeLabel :: Int -> Char -> String
  makeLabel index icon = show index ++ ": " ++ icon : " "

  icons :: String
  icons = "\xf269\xf120\xf121\xf02d\xf128\xf128\xf128\xf001\xf292\xf086"

myKeys :: IORef Bool -> XConfig Layout -> Map (KeyMask, KeySym) (X ())
myKeys updateVar XConfig { modMask = modm } =
  M.fromList
    $  workspaceKeybindings
    ++ screenWorkspaceKeybindings
    ++
      -- launching and killing programs
       [ ((modm .|. shiftMask, xK_Return), spawn myTerminal)
       , ((modm .|. shiftMask, xK_c), kill)
       , ((modm, xK_space), sendMessage NextLayout)
       , ((modm, xK_n), refresh)
       ,
        -- move focus up or down the window stack
         ((modm, xK_Tab), windows W.focusDown)
       , ((modm .|. shiftMask, xK_Tab), windows W.focusUp)
       , ((modm, xK_j), windows W.focusDown)
       , ((modm, xK_k), windows W.focusUp)
       , ((modm, xK_m), windows W.focusMaster)
       , ((modm, xK_w), spawn "rofi -show window")
       , ((modm .|. shiftMask, xK_f), liftIO $ modifyIORef' updateVar not)
       ,
        -- modifying the window order
         ((modm, xK_Return), windows W.swapMaster)
       , ((modm .|. shiftMask, xK_j), windows W.swapDown)
       , ((modm .|. shiftMask, xK_k), windows W.swapUp)
       , ((modm .|. controlMask, xK_period), onGroup W.focusUp')
       , ((modm .|. controlMask, xK_comma), onGroup W.focusDown')
       , ((modm .|. altMask, xK_l), sendMessage $ ExpandTowards R)
       , ((modm .|. altMask, xK_h), sendMessage $ ExpandTowards L)
       , ((modm .|. altMask, xK_j), sendMessage $ ExpandTowards D)
       , ((modm .|. altMask, xK_k), sendMessage $ ExpandTowards U)
       , ((modm .|. altMask, xK_r), sendMessage Rotate)
       , ((modm .|. altMask, xK_m), sendMessage Swap)
       , ((modm .|. altMask, xK_n), sendMessage FocusParent)
       , ((modm .|. ctrlMask, xK_n), sendMessage SelectNode)
       , ((modm .|. shiftMask, xK_n), sendMessage MoveNode)
       ,
        -- tabs
         ((modm .|. controlMask, xK_h), sendMessage $ pullGroup L)
       , ((modm .|. controlMask, xK_l), sendMessage $ pullGroup R)
       , ((modm .|. controlMask, xK_k), sendMessage $ pullGroup U)
       , ((modm .|. controlMask, xK_j), sendMessage $ pullGroup D)
       , ((modm .|. controlMask, xK_m), withFocused (sendMessage . MergeAll))
       , ((modm .|. controlMask, xK_u), withFocused (sendMessage . UnMerge))
       ,
        -- floating layer support
         ((modm, xK_t), withFocused $ windows . W.sink)
       , ( (modm, xK_c)
         , placeFocused $ withGaps (16, 16, 16, 16) (smart (0.5, 0.5))
         )
       ,
        -- quit
         ((modm .|. shiftMask, xK_q), io exitSuccess)
       ,
        -- restart
         ( (modm, xK_q)
         , spawn
           "if type xmonad; then xmonad --recompile && xmonad --restart;\
            \else xmessage xmonad not in \\$PATH: \"$PATH\"; fi"
         )
       ,
        -- Run xmessage with a summary of the default keybindings (useful
        -- for beginners)
         ( (modm .|. shiftMask, xK_plus)
         , spawn $ concat ["echo \"", help, "\" | xmessage -file -"]
         )
       ,
        -- Toggle fullscreen
         ((modm, xK_f), sendMessage (Toggle "Full"))
       ,
        -- Hide or show named scratchpads
         ((modm, xK_Down), namedScratchpadAction myScratchpads "termpad")
       , ((modm, xK_Up), namedScratchpadAction myScratchpads "mupad")
       , ((modm, xK_Right), namedScratchpadAction myScratchpads "empad")
       , ((modm, xK_Left), namedScratchpadAction myScratchpads "chatpad")
       , ((modm, xK_Page_Up), namedScratchpadAction myScratchpads "notepad")
       ,
        -- Copy current window to every workspace
         ((modm, xK_v), windows copyToAll)
       ,
        -- Remove all other copies of this window
         ((modm .|. shiftMask, xK_v), killAllOtherCopies)
       ]
 where
  ctrlMask = controlMask
  altMask  = mod1Mask

-- | Creates keybindings for workspaces.
workspaceKeybindings :: [((KeyMask, KeySym), X ())]
workspaceKeybindings = concatMap makeKeybinding pairs
 where
  pairs = zip myWorkspaces $ [xK_1 .. xK_9] ++ [xK_0]

  -- | Creates two keybindings for every workspace, one for
  -- switching to that workspace and one for moving the window
  -- to that workspace.
  makeKeybinding :: (String, KeySym) -> [((KeyMask, KeySym), X ())]
  makeKeybinding (ws, key) =
    [ ((myModMask, key)              , windows $ W.greedyView ws)
    , ((myModMask .|. shiftMask, key), windows $ W.shift ws)
    ]

-- mod-{a,s,d} %! Switch to physical/Xinerama screens 1, 2, or 3
-- mod-shift-{a,s,d} %! Move client to screen 1, 2, or 3
screenWorkspaceKeybindings :: [((KeyMask, KeySym), X ())]
screenWorkspaceKeybindings = concatMap makeKeybinding pairs
 where
  pairs = zip [0 ..] [xK_a, xK_s, xK_d]

  -- | Creates two keybindings for every screenworkspace, one
  -- for switching to that workspace and one for moving the
  -- window to that workspace.
  makeKeybinding :: (PhysicalScreen, KeySym) -> [((KeyMask, KeySym), X ())]
  makeKeybinding (sc, key) =
    [ ((myModMask, key)              , viewScreen def sc)
    , ((myModMask .|. shiftMask, key), sendToScreen def sc)
    ]

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines
  [ "The mod button is Mod5 (or Super)'. My keybindings:"
  , ""
  , "-- launching and killing programs"
  , "mod-Shift-Enter         Launch termite"
  , "mod-Shift-c             Close/kill the focused window"
  , "mod-Space               Rotate through the available layout algorithms"
  , "mod-Shift-Space         Reset the layouts on the current workSpace"
  , "mod-down                Open terminal scratchpad"
  , "mod-up                  Open music scratchpad"
  , "mod-right               Open Emacs scratchpad"
  , "mod-left                Open Weechat scratchpad"
  , "mod-n                   Resize/refresh viewed windows to the correct size"
  , "mod-f                   Toggle fullscreen"
  , ""
  , "-- move focus up or down the window stack"
  , "mod-Tab                Move focus to the next window"
  , "mod-Shift-Tab          Move focus to the previous window"
  , "mod-j                  Move focus to the next window"
  , "mod-k                  Move focus to the previous window"
  , "mod-m                  Move focus to the master window"
  , "mod-Ctrl-,             Move focus up inside a tabbed window group"
  , "mod-Ctrl-.             Move focus down inside a tabbed window group"
  , "mod-Shift-f            Toggle mouse follows focus"
  , ""
  , "-- modifying the window order"
  , "mod-Return             Swap the focused window and the master window"
  , "mod-Shift-j            Swap the focused window with the next window"
  , "mod-Shift-k            Swap the focused window with the previous window"
  , ""
  , "-- floating layer support"
  , "mod-t                  Push window back into tiling"
  , "mod-c                  Put floating window in center"
  , ""
  , "-- quit, or restart"
  , "mod-Shift-q            Quit xmonad"
  , "mod-q                  Restart xmonad"
  , ""
  , "-- Workspaces & screens"
  , "mod-[1..9]             Switch to workSpace N"
  , "mod-Shift-[1..9]       Move client to workspace N"
  , "mod-{a,s,d}            Switch to physical/Xinerama screens 1, 2, or 3"
  , "mod-Shift-{a,s,d}      Move client to screen 1, 2, or 3"
  , "mod-v                  Show current window on every workspace"
  , "mod-Shift-v            Remove all other copies of current window"
  , "-- Resizing and rotating"
  , "mod-Alt-[l,h,j,k]      Expand window towards right, left, down and up"
  , "mod-Alt-r              Rotate the partition tree"
  , "mod-Alt-s              Swap two nodes in the partition tree"
  , "mod-Alt-n              Focus on the parent node in the partition tree"
  , "mod-Ctrl-[l,h,j,k]     Pull in window from right, left, up and down into group with selected window/group"
  , "mod-Ctrl-u             Unmerge focused window from tab group"
  , "mod-Ctrl-m             Merge all windows into a tab group"
  , "mod-Ctrl-n             Select focused node"
  , "mod-Shift-n            Move selected node"
  , ""
  , "-- Mouse bindings: default actions bound to mouse events"
  , "mod-button1            Float the window and move it by dragging"
  , "mod-button2            Raise the window to the top of the stack"
  , "mod-button3            Float the window and resize it by dragging"
  , ""
  , "-- Help"
  , "mod-Shift-plus         Show this help message."
  ]

-- toggleLayouts makes it possible for us to toggle the first layout
-- argument, while remembering the previous layout. Here we can toggle
-- full-screen.
myLayout =
  toggleLayouts (noBorders Full)
    .   avoidStruts
    .   smartBorders
    .   gaps (zip [U, R, D, L] (repeat spaceWidth))
    .   windowNavigation
    $   tabbedBSP
    ||| tabs
 where
  tabbedBSP = subTabbed (spacing spaceWidth emptyBSP)
  tabs      = tabbed shrinkText
    $ def { fontName = "xft:Iosevka Nerd Font Mono:style=Regular" }
  spaceWidth = 5

-- | Log configuration
myPP :: PP
myPP = filterOutWsPP [scratchpadWorkspaceTag] $ def
  { ppCurrent = xmobarColor "#83a598" ""
  , ppVisible = wrap "(" ")"
  , ppTitle   = xmobarColor "#d3869b" "" . shorten 20
  , ppUrgent  = xmobarColor "red" "yellow"
  , ppLayout  = xmobarColor "#fabd2f" "" . formatLayout
  }
 where
  formatLayout x = case x of
    "Tabbed Simplest"    -> "[T]"
    "Tabbed Spacing BSP" -> "[+]"
    _                    -> x

-- | Log configuration
mySB :: StatusBarConfig
mySB = statusBarProp "~/.xmonad/xmobar" (pure myPP)

-- | Wire it all up and start XMonad
main :: IO ()
main = do
  updateVar <- newIORef True
  xmonad . withSB mySB . ewmh . docks $ def
    { modMask            = myModMask
    , terminal           = myTerminal
    , layoutHook         = myLayout
    , manageHook         = myManageHook
    , workspaces         = myWorkspaces
    , handleEventHook    = handleEventHook def
    , startupHook        = myStartupHook
    , logHook            = whenX (liftIO $ readIORef updateVar)
                               $ updatePointer (0.5, 0.5) (0.0, 0.0)
    , keys               = myKeys updateVar
    , normalBorderColor  = "#474646"
    , focusedBorderColor = "#83a598"
    }
