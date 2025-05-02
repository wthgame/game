import Vide, { Derivable, read, Show } from "@rbxts/vide";
import { Padding } from "core/client/ui/components/Padding";
import { Text, TextStyle } from "core/client/ui/components/Text";
import { TriangularSurface } from "core/client/ui/components/TriangularSurface";
import { px } from "core/client/ui/px";
import { TowerInfo } from "game/shared/areas";

export interface TowerRunViewProps {
	time: Derivable<number>;
	info: Derivable<Maybe<TowerInfo>>;
}

export function TowerRunView({ time, info }: TowerRunViewProps) {
	const minutes = () => math.floor((read(time) / 3600) * 60);
	const seconds = () => math.floor(read(time) % 60);
	const miliseconds = () => math.floor(((read(time) % 60) % 1) * 100);
	const formattedMinutes = () => (minutes() > 10 ? tostring(minutes()) : `0${minutes()}`);
	const formattedSeconds = () => (seconds() > 10 ? tostring(math.floor(seconds())) : `0${math.floor(seconds())}`);
	const formattedMiliseconds = () =>
		miliseconds() > 10 ? tostring(math.floor(miliseconds())) : `0${math.floor(miliseconds())}`;

	return (
		<>
			<uilistlayout FillDirection="Vertical" HorizontalAlignment="Center" />
			<TriangularSurface
				automaticSize={Enum.AutomaticSize.XY}
				anchorPoint={new Vector2(0.5, 0)}
				color={new Color3()}
				visibility={0.5}
				position={UDim2.fromScale(0.5, 0)}
				radiusPx={100}
			>
				<Padding padding={() => new UDim(0, px(16))}></Padding>
				<Text
					text={() => `${formattedMinutes()}:${formattedSeconds()}.${formattedMiliseconds()}`}
					textStyle={TextStyle.Text}
				></Text>
			</TriangularSurface>
			<Show
				when={() => read(info) !== undefined}
				children={() => <Text text={() => read(info)!.name} textStyle={TextStyle.Label}></Text>}
			/>
		</>
	);
}
