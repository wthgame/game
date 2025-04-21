import Vide, { Derivable, PropsWithChildren, read } from "@rbxts/vide";
import assets from "game/shared/assets";
import { BaseProps, LayoutProps } from "../types";

export const TRIANGULAR_SHEEN_IMAGE = assets.ui.triangularBorderSheen;
export const TRIANGULAR_SHEEN_SLICE_CENTER = new Rect(new Vector2(100, 100), new Vector2(412, 412));

export const TRIANGULAR_SHEEN_CORNER_SIZE_PX = 100;

export interface TriangularSheenProps extends BaseProps, LayoutProps, PropsWithChildren {
	visibility?: Derivable<number>;
	radiusPx?: Derivable<number>;
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

	visibility = 0.5,
	radiusPx = TRIANGULAR_SHEEN_CORNER_SIZE_PX,
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
			Visible={() => read(visibility) < 0.995}
			ScaleType={Enum.ScaleType.Slice}
			SliceCenter={TRIANGULAR_SHEEN_SLICE_CENTER}
			SliceScale={() => read(radiusPx) / TRIANGULAR_SHEEN_CORNER_SIZE_PX}
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
			SliceScale={() => read(radiusPx) / TRIANGULAR_SHEEN_CORNER_SIZE_PX}
			Activated={onClick}
			MouseEnter={onHover}
			MouseLeave={onHoverEnd}
		>
			{children}
		</imagebutton>
	);
}
