// import Vide, { Derivable } from "@rbxts/vide";
// import { TriangularSurface } from "../components/TriangularSurface";
// import { px } from "../px";

// export interface ButtonTimerProps {
// 	progress: Derivable<number>;
// }

// export function ButtonTimer({ progress }: ButtonTimerProps) {
// 	// https://cdn.discordapp.com/attachments/1303215496396673076/1361728472581673051/Anh_man_hinh_2025-04-15_luc_22.42.32.png?ex=67ffcff7&is=67fe7e77&hm=5d2a99005ae4982e443a34f554b62167a036113f2e83b7f21975168b4307e377&
// 	return (
// 		<TriangularSurface
// 			anchorPoint={new Vector2(0.5, 0.5)}
// 			position={UDim2.fromScale(0.5, 0.5)}
// 			size={() => UDim2.fromOffset(px(128), px(48))}
// 			radiusPx={100}
// 			color={new Color3()}
// 		>
// 			<frame
// 				BackgroundTransparency={0.5}
// 				AnchorPoint={new Vector2(0.5, 0.5)}
// 				Position={UDim2.fromScale(0.5, 0.5)}
// 				Rotation={45}
// 				Size={() => UDim2.fromScale(math.sqrt(1), math.sqrt(1))}
// 				SizeConstraint="RelativeXX"
// 				ClipsDescendants
// 			>
// 				{/* <frame
// 					AnchorPoint={new Vector2(0.5, 0.5)}
// 					Position={UDim2.fromScale(0, 1)}
// 					Rotation={-45}
// 					Size={() => new UDim2(read(progress) * 2.85, 0, 0, px(45))}
// 				></frame> */}
// 			</frame>
// 		</TriangularSurface>
// 	);
// }
