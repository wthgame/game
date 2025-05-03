import Vide from "@rbxts/vide";
import { sans } from "../fonts";
import { rem } from "../rem";
import { BaseTriangularButton, BaseTriangularButtonProps } from "./BaseTriangularButton";

export interface PrimaryTriangularButtonProps
	extends Omit<
		BaseTriangularButtonProps,
		"bgColor" | "bgHoverColor" | "rippleColor" | "labelFont" | "labelSize" | "labelColor"
	> {}
export function PrimaryTriangularButton({
	name = "PrimaryTriangularButton",
	zIndex,
	layoutOrder,

	position,
	anchorPoint,
	size,
	automaticSize = Enum.AutomaticSize.XY,

	padding,
	paddingX = () => new UDim(0, rem(1.5)),
	paddingY = () => new UDim(0, rem(0.5)),
	paddingTop,
	paddingLeft,
	paddingRight,
	paddingBottom,

	children,

	buttonLabel,
	buttonIcon,
	onClick,
	visibility = 0,
}: PrimaryTriangularButtonProps) {
	return (
		<BaseTriangularButton
			name={name}
			zIndex={zIndex}
			layoutOrder={layoutOrder}
			position={position}
			anchorPoint={anchorPoint}
			size={size}
			automaticSize={automaticSize}
			padding={padding}
			paddingX={paddingX}
			paddingY={paddingY}
			paddingTop={paddingTop}
			paddingLeft={paddingLeft}
			paddingRight={paddingRight}
			paddingBottom={paddingBottom}
			// Life is too short to worry about theme colors rn
			// TODO: worry about theme colors
			bgColor={() => new Color3(0.7, 0.7, 0.7)}
			bgHoverColor={() => new Color3(0.6, 0.6, 0.6)}
			rippleColor={() => new Color3(0.3, 0.3, 0.3)}
			labelFont={sans()}
			labelSize={() => rem(1.5)}
			labelColor={() => new Color3(0.3, 0.3, 0.3)}
			buttonLabel={buttonLabel}
			buttonIcon={buttonIcon}
			onClick={onClick}
			visibility={visibility}
		>
			{children}
		</BaseTriangularButton>
	);
}
