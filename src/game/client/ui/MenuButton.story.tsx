import Vide from "@rbxts/vide";
import { useRem } from "core/client/ui/rem";
import { setWTHAsDefaultLogger } from "core/shared/log";
import { MenuButton } from "./MenuButton";

export = {
	vide: Vide,
	story: () => {
		setWTHAsDefaultLogger();
		useRem();
		return <MenuButton />;
	},
};
