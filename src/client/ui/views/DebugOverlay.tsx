import Vide, { read, Derivable } from "@rbxts/vide";
import { Text, TextStyle } from "../components/Text";
import { SemVer } from "@rbxts/semver";

export interface DebugOverlayProps {
	fps: Derivable<number>;
	memoryMegabytes: Derivable<number>;
	today: Derivable<DateTime>;
	realname: Derivable<string>;
	codename: Derivable<string>;
	version: Derivable<SemVer>;
}

export function DebugOverlay({ fps, memoryMegabytes, today, realname, codename, version }: DebugOverlayProps) {
	let layoutOrder = 0;

	return (
		<frame Size={UDim2.fromScale(1, 1)} BackgroundTransparency={1}>
			<uilistlayout
				FillDirection={Enum.FillDirection.Vertical}
				VerticalAlignment={Enum.VerticalAlignment.Bottom}
				HorizontalAlignment={Enum.HorizontalAlignment.Left}
				SortOrder={Enum.SortOrder.LayoutOrder}
			/>
			<Text
				text={() => `${read(realname)} (${read(codename)}) v${read(version).toString()}`}
				textStyle={TextStyle.Text}
				layoutOrder={layoutOrder++}
			/>
			<Text
				text={() => `Framerate: ${math.round(read(fps))}fps`}
				textStyle={TextStyle.Text}
				layoutOrder={layoutOrder++}
			/>
			<Text
				text={() => `Memory: ${math.round(read(memoryMegabytes))}mb`}
				textStyle={TextStyle.Text}
				layoutOrder={layoutOrder++}
			/>
			<Text
				text={() => `Today is ${read(today).FormatUniversalTime("LL", "vi-vn")} in Vietnam`}
				textStyle={TextStyle.Text}
				layoutOrder={layoutOrder++}
			/>
		</frame>
	);
}
