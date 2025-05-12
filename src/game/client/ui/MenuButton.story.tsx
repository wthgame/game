import Vide from "@rbxts/vide";
import { useRem } from "core/client/ui/rem";
import { MenuButton } from "./MenuButton";

export = {
	vide: Vide,
	story: () => {
		useRem();
		return <MenuButton />;
	},
};
