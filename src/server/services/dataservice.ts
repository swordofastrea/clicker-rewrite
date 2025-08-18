import type { OnStart } from "@flamework/core";
import { Flamework, Service } from "@flamework/core";
import type { Profile } from "@rbxts/profile-store";
import ProfileStore from "@rbxts/profile-store";
import { Players } from "@rbxts/services";

import type { Leaderstats } from "./leaderstats";

interface ProfileTemplate {
	Clicks: number;
	Rebirths: number;
}

@Service()
export class DataService implements OnStart {
	private readonly profileTemplate: ProfileTemplate = {
		Clicks: 0,
		Rebirths: 0,
	};
	private readonly DataService = ProfileStore.New("PlayerData", this.profileTemplate);
	private readonly Profiles: Map<number, Profile<ProfileTemplate>> = new Map<
		number,
		Profile<ProfileTemplate>
	>();

	constructor(private readonly leaderstats: Leaderstats) {}

	public onStart(): void {
		Players.PlayerAdded.Connect((player: Player) => {
			this.LoadPlayerProfile(player).catch((err: unknown) => {
				player.Kick(`Failed to load data because of ${err}. Please try rejoining.`);
			});
		});
		Players.PlayerRemoving.Connect((player: Player) => {
			void this.SavePlayerProfile(player);
		});
		for (const player of Players.GetPlayers()) {
			this.LoadPlayerProfile(player).catch((err: unknown) => {
				player.Kick(`Failed to load data because of ${err}. Please try rejoining.`);
			});
		}
	}

	public async LoadPlayerProfile(player: Player): Promise<void> {
		const profile = this.DataService.StartSessionAsync("Player_" + player.UserId);
		this.Profiles.set(player.UserId, profile);
		profile.Reconcile();
		print("Loaded profile for ", player.Name, " with data: ", profile.Data);
	}

	public async SavePlayerProfile(player: Player): Promise<void> {
		const profile = this.Profiles.get(player.UserId);
		if (profile) {
			profile.EndSession();
			print("Saved profile for ", player.Name, " with data: ", profile.Data);
			this.Profiles.delete(player.UserId);
		}
	}

	public async GetPlayerProfile(player: Player): Promise<ProfileTemplate> {
		const playerProfile = this.Profiles.get(player.UserId);
		if (playerProfile) {
			return playerProfile.Data;
		}

		error("Player profile not found");
	}

	public async UpdatePlayerData(player: Player, stat: string, value: number): Promise<string> {
		const playerProfile = this.Profiles.get(player.UserId);
		const validValuesGuard = Flamework.createGuard<keyof ProfileTemplate>();
		if (playerProfile && validValuesGuard(stat)) {
			playerProfile.Data[stat] = value;
			this.leaderstats.UpdateLeaderstats(player, stat, value).catch((err: unknown) => error(err));
		}

		return "No update made, either player profile was unsuccessfully retrieved or stat was invalid.";
	}
}
