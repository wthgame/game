import { UserId } from "./constants/userids";

export enum CreditedUserRole {
	Director,
	TowerBuilder,
	LobbyBuilder,
	Scripter,
	Writer,
	OSTComposer,
}

export interface CreditedUser {
	kind: "user";
	userId: UserId;
	roles: Set<CreditedUserRole>;
}

export type Credited = CreditedUser;

export interface CreditedGroup {
	label?: string;
	acknowledged: Credited[];
}

export const ACKNOWLEDGEMENTS: CreditedGroup[] = [
	{
		label: "Team Fireworks",
		acknowledged: [
			{
				kind: "user",
				userId: UserId.ImNotFireMan123,
				roles: new Set([
					CreditedUserRole.Director,
					CreditedUserRole.TowerBuilder,
					CreditedUserRole.LobbyBuilder,
					CreditedUserRole.Scripter,
					CreditedUserRole.Writer,
				]),
			},
			{
				kind: "user",
				userId: UserId.Miantoz1980,
				roles: new Set([CreditedUserRole.LobbyBuilder, CreditedUserRole.TowerBuilder]),
			},
			{
				kind: "user",
				userId: UserId.Creepyrafa_rayitno,
				roles: new Set([CreditedUserRole.LobbyBuilder]),
			},
			{
				kind: "user",
				userId: UserId.thefloodescaper11,
				roles: new Set([CreditedUserRole.TowerBuilder]),
			},
			{
				kind: "user",
				userId: UserId.Talik_Roy,
				roles: new Set([CreditedUserRole.TowerBuilder]),
			},
			// TODO: Confirmed
			{
				kind: "user",
				userId: UserId.randomcoolers,
				roles: new Set([CreditedUserRole.TowerBuilder]),
			},
			{
				kind: "user",
				userId: UserId.The_CrazyNUGGY001,
				roles: new Set([CreditedUserRole.TowerBuilder]),
			},
			{
				kind: "user",
				userId: UserId.Nugget_TheCoolOne,
				roles: new Set([CreditedUserRole.TowerBuilder]),
			},
			// TODO: Moon
			// TODO: Cave
			{
				kind: "user",
				userId: UserId.LoozeBlox,
				roles: new Set([CreditedUserRole.OSTComposer]),
			},
		],
	},
];
