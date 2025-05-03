import Vide, { Derivable, read } from "@rbxts/vide";
import { NumberSpinner } from "core/client/ui/components/NumberSpinner";
import { Padding } from "core/client/ui/components/Padding";
import { Text } from "core/client/ui/components/Text";
import { TriangularSurface } from "core/client/ui/components/TriangularSurface";
import { rem } from "core/client/ui/rem";
import { fonts } from "core/client/ui/styles";
import { TowerInfo } from "game/shared/areas";

export interface RunInfoProps {
	elaspedTime: Derivable<number>;
	towerInfo: Derivable<TowerInfo>;
}

export function RunInfo({ elaspedTime, towerInfo }: RunInfoProps) {
	const hours = () => math.floor(read(elaspedTime) / 3600);
	const minutes = () => math.floor(read(elaspedTime) / 60);
	const seconds = () => math.floor(read(elaspedTime) % 60);
	const miliseconds = () => math.floor((read(elaspedTime) % 60) * 100);

	let timeLayoutOrder = 1;

	return (
		<TriangularSurface
			automaticSize={Enum.AutomaticSize.XY}
			anchorPoint={new Vector2(0.5, 0)}
			position={() => UDim2.fromScale(0.5, 0).add(UDim2.fromOffset(0, rem(1)))}
			color={new Color3()}
			size={() => new UDim2(0, rem(20), 0, rem(4))}
			visibility={0.5}
		>
			{/* <TriangularSheen size={UDim2.fromScale(1, 1)} zIndex={2}> */}
			<uilistlayout FillDirection="Vertical" HorizontalAlignment="Center" VerticalAlignment="Center" />
			<Padding paddingTop={() => new UDim(0, rem(0.5))} paddingBottom={() => new UDim(0, rem(0.75))} />
			<frame AutomaticSize="X" BackgroundTransparency={1} Size={() => UDim2.fromOffset(0, rem(3))}>
				<uilistlayout
					FillDirection="Horizontal"
					HorizontalAlignment="Center"
					VerticalAlignment="Center"
					SortOrder="LayoutOrder"
				/>
				<NumberSpinner
					value={hours}
					numDigits={2}
					font={fonts.serif.bold}
					textColor={new Color3(1, 1, 1)}
					size={() => UDim2.fromOffset(0, rem(3))}
					layoutOrder={timeLayoutOrder++}
				/>
				<Text
					text=":"
					font={fonts.serif.regular}
					textColor={new Color3(1, 1, 1)}
					textSize={() => rem(2)}
					layoutOrder={timeLayoutOrder++}
				/>
				<NumberSpinner
					value={minutes}
					numDigits={2}
					font={fonts.serif.bold}
					textColor={new Color3(1, 1, 1)}
					size={() => UDim2.fromOffset(0, rem(3))}
					layoutOrder={timeLayoutOrder++}
				/>
				<Text
					text=":"
					font={fonts.serif.regular}
					textColor={new Color3(1, 1, 1)}
					textSize={() => rem(2)}
					layoutOrder={timeLayoutOrder++}
				/>
				<NumberSpinner
					value={seconds}
					numDigits={2}
					font={fonts.serif.bold}
					textColor={new Color3(1, 1, 1)}
					size={() => UDim2.fromOffset(0, rem(3))}
					layoutOrder={timeLayoutOrder++}
				/>
				<Text
					text={() => {
						const decimals = tostring(miliseconds()).sub(1, 2);
						if (decimals.size() < 2) return `0${decimals}`;
						return decimals;
					}}
					size={UDim2.fromScale(0, 0.75)}
					textAlignY="bottom"
					font={fonts.serif.bold}
					textColor={new Color3(1, 1, 1)}
					textSize={() => rem(1.25)}
					layoutOrder={timeLayoutOrder++}
					paddingLeft={() => new UDim(0, rem(0.05))}
				/>
			</frame>
			<Text
				text={() => read(towerInfo).name}
				font={fonts.serif.regular}
				textColor={new Color3(1, 1, 1)}
				textSize={() => rem(1.5)}
			/>
			{/* </TriangularSheen> */}
		</TriangularSurface>
	);
}
