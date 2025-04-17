import Vide, { Derivable, read } from "@rbxts/vide";
import { TowerInfo } from "shared/areas";
import { ButtonStyle } from "../components/Button";
import { Text, TextStyle } from "../components/Text";
import { TriangularButton } from "../components/TriangularButton";

export interface TowerPreviewProps {
	info: Derivable<TowerInfo>;
	onRunRequested: () => void;
}

export function TowerPreview({ info, onRunRequested }: TowerPreviewProps) {
	let layoutOrder = 1;

	return (
		<frame BackgroundTransparency={0.8} Size={UDim2.fromOffset(256, 256)}>
			<uiaspectratioconstraint AspectRatio={2 / 3} />
			<uilistlayout SortOrder={Enum.SortOrder.LayoutOrder}></uilistlayout>
			<Text textStyle={TextStyle.Title} text={() => read(info).title} layoutOrder={layoutOrder++} />
			<TriangularButton buttonStyle={ButtonStyle.Primary} buttonLabel="Play" layoutOrder={layoutOrder++} />
		</frame>
	);
}
