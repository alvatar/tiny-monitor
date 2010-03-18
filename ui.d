/+ Copyright (c) 2010 by Álvaro Castro-Castilla, All Rights Reserved.         +/
/+ Licensed under the GPLv3 license, see LICENSE file for full description.   +/

module monitor.ui;

private {
	import std.string;
	import std.stdio;
	import core.sys.posix.unistd;

	import monitor.curses;
	import monitor.status;
}

interface Ui {
	void init( Status
			, void delegate()
			, void delegate(bool)
			, void delegate() );
	void finalize();
	void loop();
}

private {
	immutable key_escape = 27;
	immutable key_space = 32;
	immutable key_a = 97;
	immutable key_z = 122;
	immutable key_s = 115;
	immutable key_x = 120;
	immutable key_d = 100;
	immutable key_c = 99;
}

/+ Possible way for keystrokes grabbing
import std.c.stdio;
extern (C) {
	import core.sys.posix.termios;
	int cfmakeraw( termios* );
}

	termios ostate;                 /* saved tty state */
    termios nstate;                 /* values for editor mode */

    // Open stdin in raw mode
    // Adjust output channel     
    tcgetattr(1, &ostate);                       /* save old state */
    tcgetattr(1, &nstate);                       /* get base of new state */
    cfmakeraw(&nstate);
    tcsetattr(1, TCSADRAIN, &nstate);      /* set mode */

   // Read characters in raw mode
    auto c = fgetc(stdin);
	printf("%c\n",c);

    // Close
    tcsetattr(1, TCSADRAIN, &ostate);
+/

class CursesUi : Ui {

	private {
		int current_getch;
		static WINDOW *mainwnd;
		static WINDOW *screen;
		WINDOW *my_win;

		void delegate() startFunc;
		void delegate(bool) updateWork;
		void delegate() stopFunc;

		Status status;
		bool working = false;
	}

	void init( Status istatus
			, void delegate() startf
			, void delegate(bool) updatef
			, void delegate() stopf ) {

		status = istatus;
		startFunc = startf;
		updateWork = updatef;
		stopFunc = stopf;

		mainwnd = initscr();
		noecho();
		cbreak();
		nodelay(mainwnd, TRUE);
		refresh(); // 1)
		wrefresh(mainwnd);
		screen = newwin(14, 80, 1, 1);
		box(screen, ACS_VLINE, ACS_HLINE);
	}

	void finalize() {
		endwin();
	}

	void loop() {
		while (true) {
			current_getch = getch();
			if (current_getch == key_escape) {
				break;
			} else if (current_getch == key_space && working) {
				working = false;
				stopFunc();
			} else if (current_getch == key_space && !working) {
				working = true;
				startFunc();
			} else if (current_getch == key_a) {
				status.working += 3600;
				updateWork(false);
			} else if (current_getch == key_z) {
				status.working -= 3600;
				updateWork(false);
			} else if (current_getch == key_s) {
				status.working += 60;
				updateWork(false);
			} else if (current_getch == key_x) {
				status.working -= 60;
				updateWork(false);
			} else if (current_getch == key_d) {
				status.working += 1;
				updateWork(false);
			} else if (current_getch == key_c) {
				status.working -= 1;
				updateWork(false);
			}
			updateDisplay();
			if (working) {
				updateWork(true);
			}
			usleep(500000);
		}
		stopFunc();
	}

	private void updateDisplay() {
		curs_set(1);
		mvwprintw(screen,1,1,"---------- SI MIRAS ESTO ES QUE NO ESTAS TRABAJANDO ----------");
		mvwprintw(screen,3,1,"Pulsa <espacio> para parar el tiempo contabilizado");
		mvwprintw(screen,4,1,"Pulsa <escape> para salir y dejar de monitorizarte");
		if (working) {
			mvwprintw(screen,7,6,"Tiempo total trabajando: (pulsa <espacio>)");
		} else {
			mvwprintw(screen,7,6,"Tiempo total trabajando: %d h. %d m. %d s.           ", status.w_hour, status.w_min, status.w_sec);
		}
		if (working) {
			mvwprintw(screen,10,1,"------------- En este momento estás trabajando -------------");
		} else {
			mvwprintw(screen,10,1,"------------- En este momento NO ESTÁS TRABAJANDO -------------");
		}
		wrefresh(screen);
		refresh();
	}
}
