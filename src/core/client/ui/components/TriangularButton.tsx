import Vide, { Derivable, effect, For, Node, PropsWithChildren, read, Show, source, untrack } from "@rbxts/vide";
import { BaseProps, LayoutProps } from "../types";
import { Padding, PaddingProps } from "./Padding";
import { px } from "../px";
import { TRIANGULAR_SURFACE_CORNER_SIZE_PX, TriangularSurface } from "./TriangularSurface";
import { Text, TextStyle } from "./Text";
import {
	BUTTON_STYLE_BG_HOVER_PALLETE,
	BUTTON_STYLE_BG_PALLETE,
	BUTTON_STYLE_BORDER_PALLETE,
	BUTTON_STYLE_RIPPLE_PALLETE,
	BUTTON_STYLE_TEXT_STYLE,
	ButtonProps,
	ButtonStyle,
} from "./Button";
import { Palette, palette, PALLETES } from "../palette";
import { useLifetime, useMotion } from "@rbxts/pretty-vide-utils";
import { TriangularSheen } from "./TriangularSheen";

const TRIANGULAR_BUTTON_RIPPLE_DURATION_SECONDS = 0.5;

export interface TriangularButtonProps extends ButtonProps {}

interface TriangularButtonRipple {
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
	paddingX = () => new UDim(0, px(16)),
	paddingY = () => new UDim(0, px(4)),
	paddingTop,
	paddingLeft,
	paddingRight,
	paddingBottom,

	children,

	buttonStyle,
	buttonLabel,
	buttonIcon,
	onClick,
	visibility = 0,
}: TriangularButtonProps) {
	const lifetime = useLifetime();
	const isHovering = source(false);

	const [bg, bgMotion] = useMotion(palette(BUTTON_STYLE_BG_HOVER_PALLETE[read(buttonStyle)]));
	effect(() =>
		bgMotion.spring(
			palette((isHovering() ? BUTTON_STYLE_BG_HOVER_PALLETE : BUTTON_STYLE_BG_PALLETE)[read(buttonStyle)]),
		),
	);

	const ripples = source(new Set<TriangularButtonRipple>());
	function createRipple() {
		const r: TriangularButtonRipple = { when: untrack(lifetime) };
		const newRipples = ripples();
		newRipples.add(r);
		ripples(newRipples);
		task.delay(
			TRIANGULAR_BUTTON_RIPPLE_DURATION_SECONDS,
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
			radiusPx={TRIANGULAR_SURFACE_CORNER_SIZE_PX}
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
						<Text text={buttonLabel!} textStyle={() => BUTTON_STYLE_TEXT_STYLE[read(buttonStyle)]} />
					)}
				/>
				{children}
			</frame>
			<TriangularSheen zIndex={2} />
			{() => {
				const instances = [];
				for (const { when } of ripples()) {
					const rippleLifetime = () => lifetime() - when;
					const rippleProgress = () => rippleLifetime() / TRIANGULAR_BUTTON_RIPPLE_DURATION_SECONDS;
					instances.push(
						<TriangularSurface
							name="Ripple"
							size={() => UDim2.fromScale(rippleProgress(), 1)}
							anchorPoint={new Vector2(0.5, 0.5)}
							position={UDim2.fromScale(0.5, 0.5)}
							visibility={() => 1 - math.abs(rippleProgress() - 1) * 0.1}
							radiusPx={TRIANGULAR_SURFACE_CORNER_SIZE_PX}
							color={() => palette(BUTTON_STYLE_RIPPLE_PALLETE[read(buttonStyle)])}
						/>,
					);
				}
				return instances;
			}}
		</TriangularSurface>
	);
}
