import type { OnStart } from "@flamework/core";
import { Flamework, Service } from "@flamework/core";
import Lyra from "@rbxts/lyra";
import { Players } from "@rbxts/services";

import type { Leaderstats } from "./leaderstats";

export interface ProfileTemplate {
	Clicks: number;
	Rebirths: number;
}

@Service()
export class DataService implements OnStart {
	private readonly profileTemplate: ProfileTemplate = {
		Clicks: 0,
		Rebirths: 0,
	};
	private readonly store = Lyra.createPlayerStore({
		name: "PlayerData",
		schema: Flamework.createGuard<ProfileTemplate>(),
		template: this.profileTemplate,
	});

	constructor(private readonly leaderstats: Leaderstats) {}

	public onStart(): void {
		Players.PlayerAdded.Connect((player: Player) => {
			this.store.loadAsync(player);
			print(`Loaded profile ${this.store.getAsync(player)} for player ${player.Name}`);
		});
		Players.PlayerRemoving.Connect((player: Player) => {
			this.store.unloadAsync(player);
			print(`Unloaded profile ${this.store.getAsync(player)} for player ${player.Name}`);
		});
		for (const player of Players.GetPlayers()) {
			this.store.loadAsync(player);
		}

		game.BindToClose(() => {
			this.store.closeAsync();
		});
	}

	public UpdatePlayerData(player: Player, stat: keyof ProfileTemplate, value: number): string {
		try {
			this.store.updateAsync(player, (data) => {
				data[stat] = value;
				return true;
			});

			this.leaderstats.UpdateLeaderstats(player, stat, value);
			return `Updated leaderstats for ${player.Name} for stat ${stat} to ${value}`;
		} catch (err) {
			error(`Failed to update leaderstats for ${player.Name}: ${err}`);
		}
	}
}
