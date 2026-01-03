#include <hyprland/src/desktop/Window.hpp>
#include <hyprland/src/managers/EventManager.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>

inline HANDLE PHANDLE = nullptr;

// Do NOT change this function.
APICALL EXPORT std::string PLUGIN_API_VERSION() { return HYPRLAND_API_VERSION; }

static void onCloseWindow(void *self, std::any data) {
  // Data is guaranteed
  const auto PWINDOW = std::any_cast<PHLWINDOW>(data);

  g_pEventManager->postEvent(SHyprIPCEvent{
      "closewindowv2", std::format("{:x},{}", PWINDOW, PWINDOW->m_class)});
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
  PHANDLE = handle;

  // Make sure we're running against the correct Hyprland version
  // ALWAYS add this to your plugins. It will prevent random crashes coming from
  // mismatched header versions.
  const std::string HASH = __hyprland_api_get_hash();
  if (HASH != GIT_COMMIT_HASH) {
    HyprlandAPI::addNotification(
        PHANDLE,
        "[ipc-closewindowv2] Mismatched headers! Headers ver "
        "is not equal to running Hyprland ver.",

        CHyprColor{1.0, 0.2, 0.2, 1.0}, 5000);
    throw std::runtime_error("[ipc-closewindowv2] Version mismatch");
  }

  // Register callbacks
  static auto closeWindow = HyprlandAPI::registerCallbackDynamic(
      PHANDLE, "closeWindow",
      [&](void *self, SCallbackInfo &info, std::any data) {
        onCloseWindow(self, data);
      });

  // Yay let's go
  HyprlandAPI::addNotification(PHANDLE,
                               "[ipc-closewindowv2] Initialized successfully!",
                               CHyprColor{0.2, 1.0, 0.2, 1.0}, 5000);
  return {"ipc-closewindowv2",
          "Adds a new IPC event with more info about windows that are being "
          "closed.",
          "zacoons", VERSION};
}

APICALL EXPORT void PLUGIN_EXIT() { ; }
