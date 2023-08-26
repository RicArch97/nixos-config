# Configuration for video (GPU)
{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  videoConfig = config.modules.hardware.video;
  device = config.modules.device;
in {
  options.modules.hardware.video = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf (videoConfig.enable) (lib.mkMerge [
    {
      hardware = {
        opengl = {
          enable = true;
          # enables Mesa (OpenGL and Vulkan)
          driSupport = true;
          driSupport32Bit = true;
        };
      };

      # permissions
      user.extraGroups = ["video"];
    }

    (lib.mkIf (device.gpu == "amd") {
      # enable amdgpu kernel module
      boot.initrd.kernelModules = ["amdgpu"];
      services.xserver.videoDrivers = ["amdgpu"];

      # enables OpenCL support
      hardware.opengl.extraPackages = [
        pkgs.rocm-opencl-icd
        pkgs.rocm-opencl-runtime
      ];
    })

    (lib.mkIf (device.gpu == "intel") {
      # enable the i915 kernel module
      boot.initrd.kernelModules = ["i915"];
      # better performance than the actual Intel driver
      services.xserver.videoDrivers = ["modesetting"];

      # OpenCL support and VAAPI
      hardware.opengl.extraPackages = [
        pkgs.intel-compute-runtime
        pkgs.intel-media-driver
        pkgs.vaapiIntel
        pkgs.vaapiVdpau
        pkgs.libvdpau-va-gl
      ];

      environment.variables.VDPAU_DRIVER = "va_gl";
    })

    (lib.mkIf (device.gpu == "nvidia") {
      services.xserver.videoDrivers = ["nvidia"];

      # hardware acceleration
      hardware.opengl.extraPackages = [pkgs.vaapiVdpau];
    })
  ]);
}
