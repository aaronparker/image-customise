# Registry Settings

## Machine-Windows11.All.json

Minimum build: 10.0.22000

Maximum build: 10.0.29999

Type: Direct

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKLM: \Software \Microsoft \Windows \CurrentVersion \Communications | ConfigureChatAutoInstall | 0 | Prevents the install of the consumer Microsoft Teams client |

## Machine.All.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: Direct

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKLM: \SOFTWARE \Microsoft \Windows \CurrentVersion \Explorer | DisableEdgeDesktopShortcutCreation | 1 | Prevents the Microsoft Edge short added to the public desktop |
| HKLM: \SOFTWARE \Microsoft \Windows NT \CurrentVersion \FontSubstitutes | MS Shell Dlg | Tahoma | Replaces the `MS Shell Dlg` font with `Tahoma` for UI consistency |
| HKLM: \SOFTWARE \Microsoft \Windows NT \CurrentVersion \FontSubstitutes | MS Shell Dlg 2 | Tahoma | Replaces the `MS Shell Dlg 2` font with `Tahoma` for UI consistency |

## Machine.Client.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: Direct

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKLM: \Software \Microsoft \Windows \CurrentVersion \Explorer | DisableEdgeDesktopShortcutCreation | 1 | Prevents the Microsoft Edge short added to the public desktop |

## User-Windows10.All.json

Minimum build: 10.0.14393

Maximum build: 10.0.20999

Type: DefaultProfile

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Accent | AccentColor | 4289992518 | Sets the accent colour on window title bars and borders |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Accent | AccentPalette | 86CAFF005FB2F2001E91EA000063B10000427500002D4F000020380000CC6A00 | Sets the accent colour on window title bars and borders |
| HKCU: \Software \Microsoft \Windows \DWM | AccentColor | 4289815296 | Sets the accent colour on window title bars and borders |
| HKCU: \Software \Microsoft \Windows \DWM | ColorizationAfterglow | 3288359857 | Sets the accent colour on window title bars and borders |
| HKCU: \Software \Microsoft \Windows \DWM | ColorizationColor | 3288359857 | Sets the accent colour on window title bars and borders |
| HKCU: \Software \Microsoft \Windows \DWM | ColorPrevalence | 1 | Sets the accent colour on window title bars and borders |

## User-Windows11.All.json

Minimum build: 10.0.22000

Maximum build: 10.0.29999

Type: DefaultProfile

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | TaskbarDa | 0 | Remove the Widgets icon from the Taskbar |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | TaskbarMn | 0 | Remove the Chat icon from the Taskbar |

## User.All.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: DefaultProfile

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKCU: \Software \Microsoft \TabletTip \1.7 | TipbandDesiredVisibility | 0 | Hides the touch keyboard on the taskbar |
| HKCU: \Software \Microsoft \Windows NT \CurrentVersion \Network \Persistent Connections | SaveConnections | No | Prevents persistent mapped drives in Explorer. Assumes scripts or GPP are used to map network drives |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \AdvertisingInfo | Enabled | 0 | Turns off the feature that lets apps use the advertising ID |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \AppHost | EnableWebContentEvaluation | 1 | Turns on Smart Screen for apps |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SystemPaneSuggestionsEnabled | 0 | Disables app suggestions in the Start menu |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | LaunchTo | 1 | Configures File Explorer to start on This PC |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | SeparateProcess | 1 | Runs File Explorer windows in different processes so that one window crash won't affect all windows |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | TaskbarGlomLevel | 1 | Configures Taskbar buttons on the primary monitor to combine when the Taskbar is full |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | MMTaskbarGlomLevel | 1 | Configures Taskbar buttons on secondary monitors to combine when the Taskbar is full |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced \People | PeopleBand | 0 | Removes the People icon from the Taskbar |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \PenWorkspace | PenWorkspaceButtonDesiredVisibility | 0 | Removes the Pen Workspace from the Taskbar |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Search | SearchboxTaskbarMode | 1 | Collapses the Search box into an icon on the Taskbar |
| HKCU: \Software \Adobe \Acrobat Reader \DC \AVAlert \cCheckbox | iAppDoNotTakePDFOwnershipAtLaunchWin10 | 1 | Prevents the default file type dialog box at Adobe Acrobat Reader DC first launch |
| HKCU: \Software \Adobe \Adobe Acrobat \DC \AVAlert \cCheckbox | iAppDoNotTakePDFOwnershipAtLaunchWin10 | 1 | Prevents the default file type dialog box at Adobe Acrobat Pro/Standard DC first launch |

## User.Server.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: DefaultProfile

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKCU: \Software \Microsoft \ServerManager | DoNotOpenServerManagerAtLogon | 1 | Prevents Server Manager from starting at login |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Themes \Personalize | EnableBlurBehind | 1 | Disable blur for the Start menu, Taskbar and windows |

## User.Virtual.json

Minimum build: 10.0.14393

Maximum build: 10.0.99999

Type: DefaultProfile

| path | name | value | note |
| ---- | ---- | ----- | ---- |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Themes \Personalize | EnableBlurBehind | 0 | Disable blur for the Start menu, Taskbar and windows |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Themes \Personalize | EnableTransparency | 0 | Disable transparency for the Start menu, Taskbar and windows |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | IconsOnly | 1 | Show icons only and not document previews |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | ListviewAlphaSelect | 0 | Disables the translucent selection rectangle in File Explorer |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | ListviewShadow | 0 | Disables drop shadows on icons in File Explorer |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | ShowCompColor | 1 | Changes the font colour for compressed NTFS files / directories |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | ShowInfoTip | 1 | Disables tooltips in File Explorer |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \Explorer \Advanced | TaskbarAnimations | 0 | Disables animations in the Taskbar |
| HKCU: \Software \Microsoft \Windows \DWM | EnableAeroPeek | 0 | Disables Peek at desktop and Taskbar thumbnail live previews |
| HKCU: \Software \Microsoft \Windows \DWM | AlwaysHibernateThumbnails | 0 | Disables Taskbar preview thumbnail cache |
| HKCU: \Control Panel \Desktop | DragFullWindows | 1 | Disables the display of the window contents when dragging |
| HKCU: \Control Panel \Desktop \WindowMetrics | MinAnimate | 0 | Disables animations for minimise and maximise actions for windows |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SubscribedContent-338393Enabled | 0 | Disables suggested content in the Settings app |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SubscribedContent-353694Enabled | 0 | Disables suggested content in the Settings app |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SubscribedContent-353696Enabled | 0 | Disables suggested content in the Settings app |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SubscribedContent-338388Enabled | 0 | Disables suggested content in the Settings app |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SubscribedContent-338389Enabled | 0 | Disables suggested content in the Settings app |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \ContentDeliveryManager | SystemPaneSuggestionsEnabled | 0 | Disables suggestions in the Start menu |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \BackgroundAccessApplications \Microsoft.Windows.Photos_8wekyb3d8bbwe | Disabled | 1 | Prevents the Photos app from running in the background |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \BackgroundAccessApplications \Microsoft.Windows.Photos_8wekyb3d8bbwe | DisabledByUser | 1 | Prevents the Photos app from running in the background |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \BackgroundAccessApplications \Microsoft.SkypeApp_kzf8qxf38zg5c | Disabled | 1 | Prevents the Skype app from running in the background |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \BackgroundAccessApplications \Microsoft.SkypeApp_kzf8qxf38zg5c | DisabledByUser | 1 | Prevents the Skype app from running in the background |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \BackgroundAccessApplications \Microsoft.YourPhone_8wekyb3d8bbwe | Disabled | 1 | Prevents the Your Phone app from running in the background |
| HKCU: \Software \Microsoft \Windows \CurrentVersion \BackgroundAccessApplications \Microsoft.YourPhone_8wekyb3d8bbwe | DisabledByUser | 1 | Prevents the Your Phone app from running in the background |
