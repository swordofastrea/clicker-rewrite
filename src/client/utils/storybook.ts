export function Storybook(
	name: string,
	caller: LuaSourceContainer,
	storyRoots?: Array<Instance>,
	groupRoots = true,
): { groupRoots: boolean; name: string; storyRoots: Array<Instance> | undefined } {
	return {
		groupRoots,
		name,
		storyRoots: storyRoots ?? caller.Parent?.GetChildren() ?? [],
	};
}
