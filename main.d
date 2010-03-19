/+ Copyright (c) 2010 by Álvaro Castro-Castilla, All Rights Reserved.         +/
/+ Licensed under the MIT license, see LICENSE file for full description.     +/

module monitor.main;

import std.stdio;
import core.sys.posix.unistd;

import monitor.status;
import monitor.ui;

int main() {
	Status status = new Status;

	string save_file = "status.dat";

	try {
		status.restoreFromFile(save_file);
	} catch {
		writeln("Problemas cargando el archivo de datos anteriores. Se considerará que acabas de comenzar a trabajar");
		sleep(2);
		status.createFromScratch();
	}

	Ui ui = new CursesUi;
	ui.init( status, &status.start, &status.update, &status.stop );
	ui.loop();

	try {
		status.saveToFile(save_file);
	} catch {
		writeln("El archivo " ~ save_file ~ "no pudo ser guardado, vuelva a pulsar <escape> para salir");
		ui.loop();
	}

	ui.finalize();

   return 0;
}
