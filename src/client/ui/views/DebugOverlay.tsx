import Vide, { read, Derivable } from "@rbxts/vide";
import { Text, TextStyle } from "../components/Text";
import { SemVer } from "@rbxts/semver";
import { TriangularButton } from "../components/TriangularButton";
import { ButtonStyle } from "../components/Button";
import { MainViewController } from "client/controllers/ui/main-view";
import { CollectionService, Players } from "@rbxts/services";

export interface DebugOverlayProps {
	fps: Derivable<number>;
	memoryMegabytes: Derivable<number>;
	today: Derivable<DateTime>;
	realname: Derivable<string>;
	codename: Derivable<string>;
	version: Derivable<SemVer>;
	toggleMainView: () => void;
}

export function DebugOverlay({
	fps,
	memoryMegabytes,
	today,
	realname,
	codename,
	version,
	toggleMainView,
}: DebugOverlayProps) {
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
			<TriangularButton
				buttonStyle={ButtonStyle.Primary}
				buttonLabel="Toggle Main View"
				layoutOrder={layoutOrder++}
				onClick={toggleMainView}
			/>
			<TriangularButton
				buttonStyle={ButtonStyle.Primary}
				buttonLabel="Toggle Debug Overlay"
				layoutOrder={layoutOrder++}
			/>
			<Text text="Dev Teleporters:" textStyle={TextStyle.Text} layoutOrder={layoutOrder++} />
			{CollectionService.GetTagged("DevTeleporter")
				.filter((v): v is BasePart => v.IsA("BasePart"))
				.sort((lhs, rhs) => lhs.Name < rhs.Name)
				.map((v) => (
					<TriangularButton
						buttonStyle={ButtonStyle.Primary}
						buttonLabel={v.Name}
						layoutOrder={layoutOrder++}
						onClick={() => {
							Players.LocalPlayer.Character?.PivotTo(v.CFrame);
						}}
					/>
				))}
		</frame>
	);
}
