import Vide, { Provider } from "@rbxts/vide";
import { currentPalette, palette, PALLETES } from "../palette";

export interface StoryThemePreviewProps {
	render: () => Vide.Node;
}

export function StoryThemePreview({ render }: StoryThemePreviewProps) {
	function renderThemePreview() {
		return (
			<frame
				Name={() => palette("name")}
				Size={UDim2.fromScale(0.5, 1)}
				BackgroundColor3={() => palette("crust")}
			>
				{render()}
			</frame>
		);
	}

	return (
		<frame Name="StoryThemePreview" BackgroundTransparency={1} Size={UDim2.fromScale(1, 1)}>
			<uilistlayout FillDirection="Horizontal" />
			<Provider context={currentPalette} value={PALLETES.dark}>
				{renderThemePreview}
			</Provider>
			<Provider context={currentPalette} value={PALLETES.light}>
				{renderThemePreview}
			</Provider>
		</frame>
	);
}
