import Vide from "@rbxts/vide";
import { Text } from "core/client/ui/components/Text";
import { TriangularSheen } from "core/client/ui/components/TriangularSheen";
// import { TriangularSheen } from "core/client/ui/components/TriangularSheen";
import { TriangularSurface } from "core/client/ui/components/TriangularSurface";
import { palette } from "core/client/ui/palette";
import { rem } from "core/client/ui/rem";
import { fonts } from "core/client/ui/styles";

export function MenuButton() {
	return (
		<frame
			Name="MenuButton"
			BackgroundTransparency={1}
			Size={() => UDim2.fromOffset(rem(10), rem(4))}
			AnchorPoint={new Vector2(0, 1)}
			Position={UDim2.fromScale(0, 1)}
			ClipsDescendants
		>
			<TriangularSurface color={() => palette("crust")} visibility={1 / 3} size={UDim2.fromScale(1, 1)}>
				<TriangularSheen color={() => palette("text")} size={UDim2.fromScale(1, 1)} visibility={0.8}>
					<Text
						automaticSize={Enum.AutomaticSize.XY}
						text="Menu"
						textSize={() => rem(2)}
						font={fonts.serif.regular}
						textColor={palette("text")}
						anchorPoint={new Vector2(0.5, 0.5)}
						position={UDim2.fromScale(0.5, 0.5)}
						textAlignX="center"
						// paddingTop={() => new UDim(0, rem(0.25))}
						// paddingLeft={() => new UDim(0, rem(1))}
					/>
				</TriangularSheen>
			</TriangularSurface>
		</frame>
	);
}
