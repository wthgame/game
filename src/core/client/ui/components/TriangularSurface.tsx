import Vide, { Derivable, PropsWithChildren, read } from "@rbxts/vide";
import assets from "core/shared/assets";
import { BaseProps, LayoutProps } from "../types";

export const TRIANGULAR_SURFACE_IMAGE = assets.ui.triangularSurface;
export const TRIANGULAR_SURFACE_SLICE_CENTER = new Rect(new Vector2(100, 100), new Vector2(412, 412));

export const TRIANGULAR_SURFACE_CORNER_SIZE_PX = 100;

export interface TriangularSurfaceProps extends BaseProps, LayoutProps, PropsWithChildren {
	color?: Derivable<Color3>;
	visibility?: Derivable<number>;
	radiusPx?: Derivable<number>;
	onClick?: () => void;
	onHover?: () => void;
	onHoverEnd?: () => void;
}

/// A surface with triangular corners.
export function TriangularSurface({
	name,
	zIndex,
	layoutOrder,

	position,
	anchorPoint,
	size,
	automaticSize,
	sizeConstraint,

	children,

	color,
	visibility = 0,
	radiusPx = 0,
	onClick,
	onHover,
	onHoverEnd,
}: TriangularSurfaceProps) {
	const isPassthrough = (onClick || onHover || onHoverEnd) === undefined;
	const defaultName = isPassthrough ? "TriangularSurface (passthrough)" : "TriangularSurface";

	return isPassthrough ? (
		<imagelabel
			Name={name ?? defaultName}
			ZIndex={zIndex}
			LayoutOrder={layoutOrder}
			Position={position}
			AnchorPoint={anchorPoint}
			Size={size}
			AutomaticSize={automaticSize}
			SizeConstraint={sizeConstraint}
			BackgroundTransparency={1}
			Image={TRIANGULAR_SURFACE_IMAGE}
			ImageColor3={color}
			ImageTransparency={visibility}
			Visible={() => read(visibility) < 0.995}
			ScaleType={Enum.ScaleType.Slice}
			SliceCenter={TRIANGULAR_SURFACE_SLICE_CENTER}
			SliceScale={() => read(radiusPx) / TRIANGULAR_SURFACE_CORNER_SIZE_PX}
		>
			{children}
		</imagelabel>
	) : (
		<imagebutton
			Name={name ?? defaultName}
			ZIndex={zIndex}
			LayoutOrder={layoutOrder}
			Position={position}
			AnchorPoint={anchorPoint}
			Size={size}
			AutomaticSize={automaticSize}
			SizeConstraint={sizeConstraint}
			BackgroundTransparency={1}
			Image={TRIANGULAR_SURFACE_IMAGE}
			ImageColor3={color}
			ImageTransparency={visibility}
			Visible={() => read(visibility) < 0.995}
			ScaleType={Enum.ScaleType.Slice}
			SliceCenter={TRIANGULAR_SURFACE_SLICE_CENTER}
			SliceScale={() => read(radiusPx) / TRIANGULAR_SURFACE_CORNER_SIZE_PX}
			Activated={onClick}
			MouseEnter={onHover}
			MouseLeave={onHoverEnd}
		>
			{children}
		</imagebutton>
	);
}
