#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

// Castar SDK additions
#include <string>
#include <thread>
#include <atomic>
#include <objbase.h> // For GUID generation
#include <cstdlib>   // For wcstombs_s

// Helper function to generate a unique device ID using a GUID
std::string GenerateUniqueDeviceID() {
    GUID guid;
    if (CoCreateGuid(&guid) == S_OK) {
        wchar_t guid_wstr[39];
        if (StringFromGUID2(guid, guid_wstr, 39)) {
            char guid_str[39];
            size_t converted_chars = 0;
            wcstombs_s(&converted_chars, guid_str, sizeof(guid_str), guid_wstr, _TRUNCATE);
            return std::string(guid_str);
        }
    }
    // Fallback in case GUID generation fails
    return "fallback-guid-generation-failed";
}

// Castar SDK Class from documentation
class CastarSdk {
public:
    bool init(const std::wstring& dllPath) {
        dll_ = LoadLibraryW(dllPath.c_str());
        if (!dll_) return false;

        SetDevKey_ = (SetDevKeyFunc)GetProcAddress(dll_, "SetDevKey");
        SetDevSn_  = (SetDevSnFunc)GetProcAddress(dll_, "SetDevSn");
        Start_     = (StartFunc)GetProcAddress(dll_, "Start");
        Stop_      = (StopFunc)GetProcAddress(dll_, "Stop");

        return SetDevKey_ && SetDevSn_ && Start_ && Stop_;
    }

    void setDevKey(const std::string& key) {
        key_ = key;
        SetDevKey_(ToGoString(key_));
    }

    void setDevSn(const std::string& sn) {
        sn_ = sn;
        SetDevSn_(ToGoString(sn_));
    }

    void start() {
        running_ = true;
        worker_ = std::thread([this] {
            Start_();
        });
    }

    void stop() {
        if (running_) {
            Stop_();
            running_ = false;
        }
        if (worker_.joinable())
            worker_.join();
    }

    ~CastarSdk() {
        stop();
        if (dll_) FreeLibrary(dll_);
    }

private:
    struct GoString {
        const char* p;
        long long n;
    };

    typedef void (*SetDevKeyFunc)(GoString);
    typedef void (*SetDevSnFunc)(GoString);
    typedef void (*StartFunc)(void);
    typedef void (*StopFunc)(void);

    static GoString ToGoString(const std::string& s) {
        return GoString{ s.c_str(), static_cast<long long>(s.size()) };
    }

    HMODULE dll_{ nullptr };
    std::thread worker_;
    std::atomic<bool> running_{ false };

    std::string key_;
    std::string sn_;

    SetDevKeyFunc SetDevKey_{ nullptr };
    SetDevSnFunc  SetDevSn_{ nullptr };
    StartFunc     Start_{ nullptr };
    StopFunc      Stop_{ nullptr };
};

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // Castar SDK Initialization
  static CastarSdk sdk;
  if (sdk.init(L"castar/client_64.dll")) {
      // Replace with your actual ClientId from the Castar dashboard
      sdk.setDevKey("cskKEkoVSxgeVx");
      // Generate and set a unique device ID
      std::string deviceId = GenerateUniqueDeviceID();
      sdk.setDevSn(deviceId);
      sdk.start();
  }

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"EPUB & PDF Reader", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
