import Vide, { Derivable, read, spring } from "@rbxts/vide";
import { palette } from "../palette";
import { rem } from "../rem";
import { BaseProps, LayoutProps } from "../types";
import { Padding } from "./Padding";
import { TriangularSheen } from "./TriangularSheen";
import { TriangularSurface } from "./TriangularSurface";

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
	size = () => UDim2.fromOffset(rem(6), rem(2)),
	automaticSize,
	sizeConstraint,

	toggled = true,
	onToggle,
}: ToggleProps) {
	const progress = spring(() => (read(toggled) ? 1 : 0), 0.25);
	const highlight = () => palette("text").Lerp(palette("surface0"), progress());
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
			radius={1}
			onClick={onToggle}
			color={() => palette("surface0").Lerp(palette("text"), progress())}
		>
			<TriangularSheen size={UDim2.fromScale(1, 1)} radius={1}>
				<Padding paddingX={() => new UDim(0, rem(0.5))} paddingY={() => new UDim(0, rem(1 / 3))} />
				<TriangularSurface
					size={() => UDim2.fromScale(2 / 3, 1)}
					// sizeConstraint={Enum.SizeConstraint.RelativeYY}
					color={highlight}
					anchorPoint={() => new Vector2(progress(), 0)}
					position={() => UDim2.fromScale(progress(), 0)}
					radius={1}
				>
					<TriangularSheen size={UDim2.fromScale(1, 1)} radius={1} color={highlight} visibility={0.8} />
				</TriangularSurface>
			</TriangularSheen>
		</TriangularSurface>
	);
}
