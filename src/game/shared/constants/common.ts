import { SemVer } from "@rbxts/semver";
import { RunService } from "@rbxts/services";

export const IS_SERVER = RunService.IsServer();
export const IS_CLIENT = RunService.IsClient();
export const IS_EDIT = RunService.IsStudio() && !RunService.IsRunning();

export const VERSION = new SemVer(1, 0, 0, "dev");

export const REAL_NAME = "Welcome to Hell";
export const CODE_NAME = "Project Vulcan";
