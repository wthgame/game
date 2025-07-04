import Vide, { Derivable, PropsWithChildren, read } from "@rbxts/vide";
import assets from "core/shared/assets";
import { BaseProps, LayoutProps } from "../types";

export const TRIANGULAR_SHEEN_IMAGE = assets["ui/triangularBorderSheen"];
export const TRIANGULAR_SHEEN_SLICE_CENTER = new Rect(new Vector2(100, 100), new Vector2(412, 412));

export interface TriangularSheenProps extends BaseProps, LayoutProps, PropsWithChildren {
	color?: Derivable<Color3>;
	visibility?: Derivable<number>;
	radius?: Derivable<number>;
	onClick?: () => void;
	onHover?: () => void;
	onHoverEnd?: () => void;
}

/// Sheen with triangular corners.
export function TriangularSheen({
	name,
	zIndex,
	layoutOrder,

	position,
	anchorPoint,
	size = UDim2.fromScale(1, 1),
	automaticSize,

	children,

	color = new Color3(1, 1, 1),
	visibility = 0.5,
	radius = 1,
	onClick,
	onHover,
	onHoverEnd,
}: TriangularSheenProps) {
	const isPassthrough = (onClick || onHover || onHoverEnd) === undefined;

	return isPassthrough ? (
		<imagelabel
			Name={name ?? "TriangularSheen (passthrough)"}
			ZIndex={zIndex}
			LayoutOrder={layoutOrder}
			Position={position}
			AnchorPoint={anchorPoint}
			Size={size}
			AutomaticSize={automaticSize}
			BackgroundTransparency={1}
			Image={TRIANGULAR_SHEEN_IMAGE}
			ImageTransparency={visibility}
			ImageColor3={color}
			Visible={() => read(visibility) < 0.995}
			ScaleType={Enum.ScaleType.Slice}
			SliceCenter={TRIANGULAR_SHEEN_SLICE_CENTER}
			SliceScale={() => read(radius)}
		>
			{children}
		</imagelabel>
	) : (
		<imagebutton
			Name={name ?? "TriangularSheen"}
			ZIndex={zIndex}
			LayoutOrder={layoutOrder}
			Position={position}
			AnchorPoint={anchorPoint}
			Size={size}
			AutomaticSize={automaticSize}
			BackgroundTransparency={1}
			Image={TRIANGULAR_SHEEN_IMAGE}
			ImageTransparency={visibility}
			Visible={() => read(visibility) < 0.995}
			ScaleType={Enum.ScaleType.Slice}
			SliceCenter={TRIANGULAR_SHEEN_SLICE_CENTER}
			SliceScale={() => read(radius)}
			Activated={onClick}
			MouseEnter={onHover}
			MouseLeave={onHoverEnd}
		>
			{children}
		</imagebutton>
	);
}
