package backend;

import openfl.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

class NoteSkinData {
	public static var noteSkins:Array<NoteSkinStructure> = [];
	public static var noteSkinArray:Array<String> = [];
	private static var noteSkinMap:Map<String, NoteSkinStructure> = new Map();

	public static function reloadNoteSkins() {
		noteSkins = [];
		noteSkinArray = [];
		noteSkinMap = new Map();

		// Cache de directorios base
		var directories:Array<Array<String>> = [[Paths.getLibraryPathForce('', 'shared'), '']];
		#if MODS_ALLOWED
		directories.push([Paths.mods(), '']);

		var enabledMods = Mods.parseList().enabled;
		var globalMods = Mods.getGlobalMods();

		for (mod in enabledMods) {
			if (globalMods.contains(mod)) {
				directories.push([Paths.mods(mod + '/'), mod]);
			}
		}
		#end

		// Leer list.txt de cada directorio
		for (dir in directories) {
			var listPath = dir[0] + 'images/noteSkins/list.txt';
			#if sys
			if (!FileSystem.exists(listPath)) continue; // Evita intentos fallidos
			#end

			var skins = CoolUtil.coolTextFile(listPath);
			for (skin in skins) {
				if (!noteSkinMap.exists(skin)) {
					var ns:NoteSkinStructure = {
						skin: skin,
						folder: dir[1],
						url: online.mods.OnlineMods.getModURL(dir[1])
					};
					noteSkins.push(ns);
					noteSkinArray.push(skin);
					noteSkinMap.set(skin, ns);
				}
			}
		}

		// Insertar el skin por defecto primero
		var defaultSkin = ClientPrefs.defaultData.noteSkin;
		noteSkins.insert(0, {skin: defaultSkin, folder: ''});
		noteSkinArray.insert(0, defaultSkin);
		noteSkinMap.set(defaultSkin, {skin: defaultSkin, folder: ''});
	}

	public static function getCurrent(?player:Int = 0):NoteSkinStructure {
		var skinName = (player == -1) 
			? ClientPrefs.data.noteSkin 
			: ClientPrefs.getNoteSkin(player);

		// Acceso en O(1) usando el Map
		var ns = noteSkinMap.get(skinName);
		if (ns == null) ns = noteSkins[0];
		return ns;
	}
}

typedef NoteSkinStructure = {
	var skin:String;
	var folder:String;
	@:optional var url:String;
}
