import Vide, { Derivable, read, spring } from "@rbxts/vide";
import { palette } from "../palette";
import { px } from "../px";
import { BaseProps, LayoutProps } from "../types";
import { Padding } from "./Padding";
import { TriangularSheen } from "./TriangularSheen";
import { TRIANGULAR_SURFACE_CORNER_SIZE_PX, TriangularSurface } from "./TriangularSurface";

export interface ToggleProps extends BaseProps, LayoutProps {
	toggled?: Derivable<boolean>;
	onToggle?: () => void;
}

export function Toggle({
	name = "Toggle",
	zIndex,
	layoutOrder,

	position,
	anchorPoint,
	size = () => UDim2.fromOffset(px(64), px(24)),
	automaticSize,
	sizeConstraint,

	toggled = true,
	onToggle,
}: ToggleProps) {
	const progress = spring(() => (read(toggled) ? 1 : 0), 0.25);
	return (
		<TriangularSurface
			name={name}
			zIndex={zIndex}
			layoutOrder={layoutOrder}
			position={position}
			anchorPoint={anchorPoint}
			size={size}
			automaticSize={automaticSize}
			sizeConstraint={sizeConstraint}
			radiusPx={TRIANGULAR_SURFACE_CORNER_SIZE_PX}
			onClick={onToggle}
			color={() => palette("bgLight").Lerp(palette("fgLight"), progress())}
		>
			<TriangularSheen size={UDim2.fromScale(1, 1)} radiusPx={TRIANGULAR_SURFACE_CORNER_SIZE_PX}>
				<Padding paddingX={() => new UDim(0, px(5))} paddingY={() => new UDim(0, px(3))} />
				<TriangularSurface
					size={() => UDim2.fromScale(2 / 3, 1)}
					// sizeConstraint={Enum.SizeConstraint.RelativeYY}
					color={() => palette("fg").Lerp(palette("bg"), progress())}
					anchorPoint={() => new Vector2(progress(), 0)}
					position={() => UDim2.fromScale(progress(), 0)}
					radiusPx={TRIANGULAR_SURFACE_CORNER_SIZE_PX}
				>
					<TriangularSheen size={UDim2.fromScale(1, 1)} radiusPx={TRIANGULAR_SURFACE_CORNER_SIZE_PX} />
				</TriangularSurface>
			</TriangularSheen>
		</TriangularSurface>
	);
}
