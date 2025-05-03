import Vide, { Derivable, read, Show, source, spring } from "@rbxts/vide";
import { NumberSpinner } from "core/client/ui/components/NumberSpinner";
import { Padding } from "core/client/ui/components/Padding";
import { Text } from "core/client/ui/components/Text";
import { TriangularSheen } from "core/client/ui/components/TriangularSheen";
import { TriangularSurface } from "core/client/ui/components/TriangularSurface";
import { rem } from "core/client/ui/rem";
import { fonts } from "core/client/ui/styles";
import { TowerInfo } from "game/shared/areas";
import { getFlooredColorOfDifficulty } from "game/shared/constants/difficulties";

export interface RunInfoProps {
	elaspedTime: Derivable<number>;
	towerInfo: Derivable<Maybe<TowerInfo>>;
}

export function RunInfo({ elaspedTime, towerInfo }: RunInfoProps) {
	const hasTowerInfo = () => read(towerInfo) !== undefined;

	const hours = () => math.floor(read(elaspedTime) / 3600);
	const minutes = () => math.floor(read(elaspedTime) / 60);
	const seconds = () => math.floor(read(elaspedTime) % 60);
	const miliseconds = () => math.floor((read(elaspedTime) % 60) * 100);

	const isHovering = source(false);

	const visibility = spring(() => (hasTowerInfo() ? 0 : 1), 0.2);
	const invisibility = () => math.abs(visibility() - 1);

	const timerTextSize = () => UDim2.fromOffset(0, rem(2));
	let timeLayoutOrder = 1;

	return (
		<TriangularSurface
			name="RunInfo"
			automaticSize={Enum.AutomaticSize.X}
			anchorPoint={() => new Vector2(0.5, 0)}
			position={() => new UDim2(0.5, 0, 0, invisibility() * rem(0.5))}
			color={new Color3()}
			size={() => new UDim2(0, rem(18), 0, rem(4))}
			visibility={() => math.map(visibility(), 0, 1, 0.5, 1)}
			onHover={() => isHovering(true)}
			onHoverEnd={() => isHovering(false)}
		>
			<TriangularSheen
				size={UDim2.fromScale(1, 1)}
				zIndex={2}
				visibility={() => math.map(visibility(), 0, 1, 0.8, 1)}
			>
				<uilistlayout FillDirection="Vertical" HorizontalAlignment="Center" />
				<Padding paddingX={() => new UDim(0, rem(3))} paddingTop={() => new UDim(0, rem(0.5))} />
				<frame Name="Timer" AutomaticSize="X" BackgroundTransparency={1} Size={timerTextSize}>
					<uilistlayout
						FillDirection="Horizontal"
						HorizontalAlignment="Center"
						VerticalAlignment="Center"
						SortOrder="LayoutOrder"
					/>
					<NumberSpinner
						name="HourSpinner"
						value={hours}
						numDigits={2}
						font={fonts.serif.bold}
						textColor={new Color3(1, 1, 1)}
						size={timerTextSize}
						layoutOrder={timeLayoutOrder++}
						visibility={visibility}
					/>
					<Text
						name="Divider"
						text=":"
						font={fonts.serif.regular}
						textColor={new Color3(1, 1, 1)}
						textSize={() => rem(1)}
						layoutOrder={timeLayoutOrder++}
						visibility={visibility}
					/>
					<NumberSpinner
						name="MinuteSpinner"
						value={minutes}
						numDigits={2}
						font={fonts.serif.bold}
						textColor={new Color3(1, 1, 1)}
						size={timerTextSize}
						layoutOrder={timeLayoutOrder++}
						visibility={visibility}
					/>
					<Text
						name="Divider"
						text=":"
						font={fonts.serif.regular}
						textColor={new Color3(1, 1, 1)}
						textSize={() => rem(1)}
						layoutOrder={timeLayoutOrder++}
						visibility={visibility}
					/>
					<NumberSpinner
						name="SecondSpinner"
						value={seconds}
						numDigits={2}
						font={fonts.serif.bold}
						textColor={new Color3(1, 1, 1)}
						size={timerTextSize}
						layoutOrder={timeLayoutOrder++}
						visibility={visibility}
					/>
					<Text
						name="Milisecond"
						text={() => {
							const decimals = tostring(miliseconds()).sub(-2);
							if (decimals.size() < 2) return `0${decimals}`;
							return decimals;
						}}
						automaticSize={Enum.AutomaticSize.None}
						size={() => new UDim2(0, rem(1.25), 0.75, 0)}
						textAlignY="bottom"
						font={fonts.serif.bold}
						textColor={new Color3(1, 1, 1)}
						textSize={() => rem(1)}
						layoutOrder={timeLayoutOrder++}
						textWrapped={false}
						paddingLeft={() => new UDim(0, rem(0.1))}
						visibility={visibility}
					/>
				</frame>
				<Show when={hasTowerInfo}>
					{() => (
						<Text
							name="TowerLabel"
							text={() => {
								const { name, title } = read(towerInfo)!;
								return isHovering() ? title : name;
							}}
							font={fonts.serif.regular}
							textColor={() => getFlooredColorOfDifficulty(read(towerInfo)!.difficulty)}
							textSize={() => rem(1)}
							visibility={visibility}
						/>
					)}
				</Show>
			</TriangularSheen>
		</TriangularSurface>
	);
}
