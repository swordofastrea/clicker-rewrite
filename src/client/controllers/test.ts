import type { OnStart } from "@flamework/core";
import { Controller } from "@flamework/core";

@Controller()
export class TestController implements OnStart {
	public onStart(): void {
		print("test");
	}
}
