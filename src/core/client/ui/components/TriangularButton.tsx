import { useLifetime, useMotion } from "@rbxts/pretty-vide-utils";
import Vide, { effect, read, Show, source, untrack } from "@rbxts/vide";
import { palette, Palette } from "../palette";
import { rem } from "../rem";
import { fonts, TextSize } from "../styles";
import { ButtonProps } from "./Button";
import { Padding } from "./Padding";
import { Text } from "./Text";
import { TriangularSheen } from "./TriangularSheen";
import { TriangularSurface } from "./TriangularSurface";

const RIPPLE_DURATION_SECONDS = 0.5;

export interface TriangularButtonProps extends ButtonProps {}

interface TriangularRipple {
	when: number;
}

// TODO: Disabling buttons
/// A button with sharp triangle corners.
export function TriangularButton({
	name = "TriangularButton",
	zIndex,
	layoutOrder,

	position,
	anchorPoint,
	size,
	automaticSize = Enum.AutomaticSize.XY,

	padding,
	paddingX = () => new UDim(0, rem(2)),
	paddingY = () => new UDim(0, rem(0.5)),
	paddingTop,
	paddingLeft,
	paddingRight,
	paddingBottom,

	children,

	bgColor = new Color3(0, 0, 0),
	bgHoverColor = new Color3(1, 1, 1),
	rippleColor = new Color3(1, 1, 1),
	labelColor = new Color3(0, 0, 0),
	labelSize = TextSize.Medium,
	labelFont = fonts.serif.bold,
	buttonLabel,
	buttonIcon,
	onClick,
	visibility = 0,
}: TriangularButtonProps) {
	const lifetime = useLifetime();
	const isHovering = source(false);

	const [bg, bgMotion] = useMotion(read(bgColor));
	effect(() => bgMotion.spring(isHovering() ? read(bgHoverColor) : read(bgColor)));

	const ripples = source(new Set<TriangularRipple>());
	function createRipple() {
		const r: TriangularRipple = { when: untrack(lifetime) };
		const newRipples = ripples();
		newRipples.add(r);
		ripples(newRipples);
		task.delay(
			RIPPLE_DURATION_SECONDS,
			(toRemove) => {
				const updatedRipples = ripples();
				updatedRipples.delete(toRemove);
				ripples(updatedRipples);
			},
			r,
		);
	}

	const contentSize = source(Vector2.zero);

	return (
		<TriangularSurface
			name={name}
			zIndex={zIndex}
			layoutOrder={layoutOrder}
			position={position}
			anchorPoint={anchorPoint}
			size={() => UDim2.fromOffset(contentSize().X, contentSize().Y)}
			automaticSize={automaticSize}
			onClick={() => {
				createRipple();
				onClick?.();
			}}
			visibility={visibility}
			color={bg}
			radius={1}
			onHover={() => isHovering(true)}
			onHoverEnd={() => isHovering(false)}
		>
			<frame
				Name="Content"
				AutomaticSize={Enum.AutomaticSize.XY}
				AbsoluteSizeChanged={contentSize}
				BackgroundTransparency={1}
				ZIndex={2}
			>
				<uilistlayout SortOrder={Enum.SortOrder.LayoutOrder} FillDirection={Enum.FillDirection.Horizontal} />
				<Padding
					padding={padding}
					paddingX={paddingX}
					paddingY={paddingY}
					paddingTop={paddingTop}
					paddingLeft={paddingLeft}
					paddingRight={paddingRight}
					paddingBottom={paddingBottom}
				/>
				<Show
					when={() => read(buttonLabel)}
					children={() => (
						<Text text={buttonLabel!} textColor={labelColor} font={labelFont} textSize={labelSize} />
					)}
				/>
				{children}
			</frame>
			<TriangularSheen zIndex={2} />
			{() => {
				const instances = [];
				for (const { when } of ripples()) {
					const rippleLifetime = () => lifetime() - when;
					const rippleProgress = () => rippleLifetime() / RIPPLE_DURATION_SECONDS;
					instances.push(
						<TriangularSurface
							name="Ripple"
							size={() => UDim2.fromScale(rippleProgress(), 1)}
							anchorPoint={new Vector2(0.5, 0.5)}
							position={UDim2.fromScale(0.5, 0.5)}
							visibility={() => 1 - math.abs(rippleProgress() - 1) * 0.1}
							radius={1}
							color={rippleColor}
						/>,
					);
				}
				return instances;
			}}
		</TriangularSurface>
	);
}

export interface ThemedTriangularButtonProps
	extends Omit<TriangularButtonProps, "bgColor" | "bgHoverColor" | "labelColor"> {}

function createTriangularButtonWrapper(bg: keyof Palette, hover: keyof Palette, text: keyof Palette) {
	return (props: ThemedTriangularButtonProps) => (
		<TriangularButton
			bgColor={() => palette(bg) as Color3}
			bgHoverColor={() => palette(hover) as Color3}
			labelColor={() => palette(text) as Color3}
			{...props}
		>
			{props.children}
		</TriangularButton>
	);
}

export const PlatinumTriangularButton = createTriangularButtonWrapper("platinumBase", "platinumHover", "platinumText");
