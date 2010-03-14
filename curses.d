/**
 * CURSES binding for D programming language.
 *
 * Copyright (c) 2007 Dejan Lekic , http://dejan.lekic.org
 *                    dejan.lekic @ (gmail.com || kcl.ac.uk)
 *
 * This source code is licensed under the BSD license.
 */

/**
 * TODO:
 * o Add mouse support.
 * o Add support for PDCURSES and make sure dl.c.curses.* builds inside MSYS.
 */

/**
Example:
-----
import dl.c.curses.curses;

version(Tango) {
  import tango.stdc.stringz;
} else version(Phobos) {
  import std.string;
  import std.stdio;
}

void create_box(int y, int x, int w, int h) {
  mvaddch(y, x, '+');
  mvaddch(y, x + w, '+');
  mvaddch(y + h, x, '+');
  mvaddch(y + h, x + w, '+');
  mvhline(y, x + 1, '-', w - 1);
  mvhline(y + h, x + 1, '-', w - 1);
  mvvline(y + 1, x, '|', h - 1);
  mvvline(y + 1, x + w, '|', h - 1);
}

int main(char[][] args) {
  int startx, starty, height, width;
  int x, y;

  initscr();
  start_color();
  cbreak();
  keypad(stdscr, TRUE);
  noecho();

  init_pair(1, COLOR_BLACK, COLOR_CYAN);

  height = 2;
  width = 30;
  starty = (LINES - height)/2;
  startx = (COLS - width)/2;

  attron(COLOR_PAIR(1));

  create_box(starty, startx, width, height);

version(Tango) {
  mvprintw(starty, startx + 3, toUtf8z(" Hello world! "));
  mvprintw(starty+1,startx+1, toUtf8z(" Type any char to exit       "));
} else version(Phobos) {
  mvprintw(starty, startx + 3, toStringz(" Hello world! "));
  mvprintw(starty+1,startx+1, toStringz(" Type any char to exit       "));
}

  mvprintw(0,0,"");
  refresh();
  x = stdscr._maxx;
  y = stdscr._maxy;
  dl.c.curses.curses.getch();

  endwin();
  return 0;
} // main() function
-----
*/
module monitor.curses;

                           // We need the FILE alias, but where is it?
version(Tango) {           // If we are using the Tango framework...
  import tango.stdc.stdio;
} else {                   // ... else we assume we are using Phobos
  import std.stdio;
}

pragma(lib, "cursesw.lib");

/**
 * Some important constants (defines in C)
 */
const uint NCURSES_MOUSE_VERSION = 1; /// TODO: Do we need this?

// helper-defines & common C-hacks
const uint TRUE = 1;
const uint FALSE = 0;

/**
 * Some important aliases.
 */
alias uint            chtype;
alias uint            mmask_t;
alias ushort          NCURSES_COLOR_T;
alias ushort          NCURSES_SIZE_T;
alias chtype          NCURSES_CH_T;
alias byte            NCURSES_BOOL;
alias uint            NCURSES_ATTR_T;
alias NCURSES_ATTR_T  attr_t;

// ............................................................ Attributes ....
const ubyte NCURSES_ATTR_SHIFT = 8;

// TODO: Replace this with compile-time function
template NCURSES_BITS(uint mask, ubyte shift)
{
  const chtype NCURSES_BITS = mask << (shift + NCURSES_ATTR_SHIFT);
} // NCURSES_BITS() template function

const chtype A_NORMAL	    = (1u - 1u);
const chtype A_ATTRIBUTES	= NCURSES_BITS!(~(1u - 1u),0);
const chtype A_CHARTEXT	  = (NCURSES_BITS!(1u,0) - 1u);
const chtype A_COLOR		  = NCURSES_BITS!(((1u) << 8) - 1u,0);
const chtype A_STANDOUT	  = NCURSES_BITS!(1u,8);
const chtype A_UNDERLINE	= NCURSES_BITS!(1u,9);
const chtype A_REVERSE	  = NCURSES_BITS!(1u,10);
const chtype A_BLINK		  = NCURSES_BITS!(1u,11);
const chtype A_DIM		    = NCURSES_BITS!(1u,12);
const chtype A_BOLD		    = NCURSES_BITS!(1u,13);
const chtype A_ALTCHARSET	= NCURSES_BITS!(1u,14);
const chtype A_INVIS		  = NCURSES_BITS!(1u,15);
const chtype A_PROTECT	  = NCURSES_BITS!(1u,16);
const chtype A_HORIZONTAL	= NCURSES_BITS!(1u,17);
const chtype A_LEFT		    = NCURSES_BITS!(1u,18);
const chtype A_LOW		    = NCURSES_BITS!(1u,19);
const chtype A_RIGHT		  = NCURSES_BITS!(1u,20);
const chtype A_TOP		    = NCURSES_BITS!(1u,21);
const chtype A_VERTICAL	  = NCURSES_BITS!(1u,22);

// XSI attributes
const chtype WA_ATTRIBUTES	= A_ATTRIBUTES;
const chtype WA_NORMAL	    = A_NORMAL;
const chtype WA_STANDOUT	  = A_STANDOUT;
const chtype WA_UNDERLINE	  = A_UNDERLINE;
const chtype WA_REVERSE	    = A_REVERSE;
const chtype WA_BLINK	      = A_BLINK;
const chtype WA_DIM		      = A_DIM;
const chtype WA_BOLD		    = A_BOLD;
const chtype WA_ALTCHARSET	= A_ALTCHARSET;
const chtype WA_INVIS	      = A_INVIS;
const chtype WA_PROTECT	    = A_PROTECT;
const chtype WA_HORIZONTAL	= A_HORIZONTAL;
const chtype WA_LEFT		    = A_LEFT;
const chtype WA_LOW		      = A_LOW;
const chtype WA_RIGHT	      = A_RIGHT;
const chtype WA_TOP		      = A_TOP;
const chtype WA_VERTICAL	  = A_VERTICAL;

// ................................................................ Colors ....
const short COLOR_BLACK	  = 0;
const short COLOR_RED	    = 1;
const short COLOR_GREEN	  = 2;
const short COLOR_YELLOW	= 3;
const short COLOR_BLUE	  = 4;
const short COLOR_MAGENTA	= 5;
const short COLOR_CYAN	  = 6;
const short COLOR_WHITE	  = 7;

alias void WINDOW; /** Opaque data type - NCURSES and PDCURSES has different
                       window structure unfortunately. */
alias void SCREEN; /** Similar with the SCREEN type. */

const ubyte ACS_LEN = 128; /// Number of characters in ACS

extern (C) {
  __gshared chtype[ACS_LEN] acs_map;
  /// X/Open CURSES functions:
  int addch (chtype);
  int addchnstr (chtype *, int);
  int addchstr (chtype *);
  int addnstr (char *, int);
  int addstr (char *);
  int attroff (NCURSES_ATTR_T);
  int attron (NCURSES_ATTR_T);
  int attrset (NCURSES_ATTR_T);
  int attr_get (attr_t *, short *, void *);
  int attr_off (attr_t, void *);
  int attr_on (attr_t, void *);
  int attr_set (attr_t, short, void *);
  int baudrate ();
  int beep  ();
  int bkgd (chtype);
  void bkgdset (chtype);
  int border (chtype,chtype,chtype,chtype,chtype,chtype,chtype,chtype);
  int box (WINDOW *, chtype, chtype);
  bool can_change_color ();
  int cbreak ();
  int chgat (int, attr_t, short, void *);
  int clear ();
  int clearok (WINDOW *,bool);
  int clrtobot ();
  int clrtoeol ();
  int color_content (short,short*,short*,short*);
  int color_set (short,void*);
  int COLOR_PAIR (int);
  int copywin (WINDOW*,WINDOW*,int,int,int,int,int,int,int);
  int curs_set (int);
  int def_prog_mode ();
  int def_shell_mode ();
  int delay_output (int);
  int delch ();
  void delscreen (SCREEN *);
  int delwin (WINDOW *);
  int deleteln ();
  WINDOW* derwin (WINDOW *,int,int,int,int);
  int doupdate ();
  WINDOW* dupwin (WINDOW *);
  int echo ();
  int echochar (chtype);
  int erase ();
  int endwin ();
  char erasechar ();
  void filter ();
  int flash ();
  int flushinp ();
  chtype getbkgd (WINDOW *);
  int getch ();
  int getnstr (char *, int);
  int getstr (char *);
  WINDOW* getwin (FILE *);
  int halfdelay (int);
  bool has_colors ();
  bool has_ic ();
  bool has_il ();
  int hline (chtype, int);
  void idcok (WINDOW *, bool);
  int idlok (WINDOW *, bool);
  void immedok (WINDOW *, bool);
  chtype inch ();
  int inchnstr (chtype *, int);
  int inchstr (chtype *);
  WINDOW* initscr ();
  int init_color (short,short,short,short);
  int init_pair (short,short,short);
  int innstr (char *, int);
  int insch (chtype);
  int insdelln (int);
  int insertln ();
  int insnstr (char *, int);
  int insstr (char *);
  int instr (char *);
  int intrflush (WINDOW *,bool);
  bool isendwin ();
  bool is_linetouched (WINDOW *,int);
  bool is_wintouched (WINDOW *);
  char* keyname (int);
  int keypad (WINDOW *,bool);
  char killchar ();
  int leaveok (WINDOW *,bool);
  char* longname ();
  int meta (WINDOW *,bool);
  int move (int, int);
  int mvaddch (int, int, chtype);
  int mvaddchnstr (int, int, chtype *, int);
  int mvaddchstr (int, int, chtype *);
  int mvaddnstr (int, int, char *, int);
  int mvaddstr (int, int, char *);
  int mvchgat (int, int, int, attr_t, short, void *);
  int mvcur (int,int,int,int);
  int mvdelch (int, int);
  int mvderwin (WINDOW *, int, int);
  int mvgetch (int, int);
  int mvgetnstr (int, int, char *, int);
  int mvgetstr (int, int, char *);
  int mvhline (int, int, chtype, int);
  chtype mvinch (int, int);
  int mvinchnstr (int, int, chtype *, int);
  int mvinchstr (int, int, chtype *);
  int mvinnstr (int, int, char *, int);
  int mvinsch (int, int, chtype);
  int mvinsnstr (int, int, char *, int);
  int mvinsstr (int, int, char *);
  int mvinstr (int, int, char *);
  int mvprintw (int,int, char *,...);
  int mvscanw (int,int, char *,...);
  int mvvline (int, int, chtype, int);
  int mvwaddch (WINDOW *, int, int, chtype);
  int mvwaddchnstr (WINDOW *, int, int, chtype *, int);
  int mvwaddchstr (WINDOW *, int, int, chtype *);
  int mvwaddnstr (WINDOW *, int, int, char *, int);
  int mvwaddstr (WINDOW *, int, int, char *);
  int mvwchgat (WINDOW *, int, int, int, attr_t, short, void *);
  int mvwdelch (WINDOW *, int, int);
  int mvwgetch (WINDOW *, int, int);
  int mvwgetnstr (WINDOW *, int, int, char *, int);
  int mvwgetstr (WINDOW *, int, int, char *);
  int mvwhline (WINDOW *, int, int, chtype, int);
  int mvwin (WINDOW *,int,int);
  chtype mvwinch (WINDOW *, int, int);
  int mvwinchnstr (WINDOW *, int, int, chtype *, int);
  int mvwinchstr (WINDOW *, int, int, chtype *);
  int mvwinnstr (WINDOW *, int, int, char *, int);
  int mvwinsch (WINDOW *, int, int, chtype);
  int mvwinsnstr (WINDOW *, int, int, char *, int);
  int mvwinsstr (WINDOW *, int, int, char *);
  int mvwinstr (WINDOW *, int, int, char *);
  int mvwprintw (WINDOW*,int,int, const char *,...);
  int mvwscanw (WINDOW *,int,int, char *,...);
  int mvwvline (WINDOW *,int, int, chtype, int);
  int napms (int);
  WINDOW* newpad (int,int);
  SCREEN* newterm (char *,FILE *,FILE *);
  WINDOW* newwin (int,int,int,int);
  int nl ();
  int nocbreak ();
  int nodelay (WINDOW *,bool);
  int noecho ();
  int nonl ();
  void noqiflush ();
  int noraw ();
  int notimeout (WINDOW *,bool);
  int overlay (WINDOW*,WINDOW *);
  int overwrite (WINDOW*,WINDOW *);
  int pair_content (short,short*,short*);
  int PAIR_NUMBER (int);
  int pechochar (WINDOW *, chtype);
  int pnoutrefresh (WINDOW*,int,int,int,int,int,int);
  int prefresh (WINDOW *,int,int,int,int,int,int);
  int printw (char *,...);
  int putp (char *);
  int putwin (WINDOW *, FILE *);
  void qiflush ();
  int raw ();
  int redrawwin (WINDOW *);
  int refresh ();
  int resetty ();
  int reset_prog_mode ();
  int reset_shell_mode ();
  int ripoffline (int, int (*)(WINDOW *, int));
  int savetty ();
  int scanw (char *,...);
  int scr_dump (char *);
  int scr_init (char *);
  int scrl (int);
  int scroll (WINDOW *);
  int scrollok (WINDOW *,bool);
  int scr_restore (char *);
  int scr_set (char *);
  int setscrreg (int,int);
  SCREEN* set_term (SCREEN *);
  int slk_attroff (chtype);
  int slk_attr_off (attr_t, void *);   /* generated:WIDEC */
  int slk_attron (chtype);
  int slk_attr_on (attr_t,void*);      /* generated:WIDEC */
  int slk_attrset (chtype);
  attr_t slk_attr ();
  int slk_attr_set (attr_t,short,void*);
  int slk_clear ();
  int slk_color (short);
  int slk_init (int);
  char* slk_label (int);
  int slk_noutrefresh ();
  int slk_refresh ();
  int slk_restore ();
  int slk_set (int,char *,int);
  int slk_touch ();
  int standout ();
  int standend ();
  int start_color ();
  WINDOW* subpad (WINDOW *, int, int, int, int);
  WINDOW* subwin (WINDOW *,int,int,int,int);
  int syncok (WINDOW *, bool);
  chtype termattrs ();
  char* termname ();
  int tigetflag (char *);
  int tigetnum (char *);
  char* tigetstr (char *);
  void timeout (int);
  int touchline (WINDOW *, int, int);
  int touchwin (WINDOW *);
  char* tparm (char *, ...);
  int typeahead (int);
  int ungetch (int);
  int untouchwin (WINDOW *);
  void use_env (bool);
  int vidattr (chtype);
  int vidputs (chtype, int (*)(int));
  int vline (chtype, int);
  int vwprintw (WINDOW *, char *,...);
  int vw_printw (WINDOW *, char *,...);
  int vwscanw (WINDOW *, char *,...);
  int vw_scanw (WINDOW *, char *,...);
  int waddch (WINDOW *, chtype);
  int waddchnstr (WINDOW *,chtype *,int);
  int waddchstr (WINDOW *,chtype *);
  int waddnstr (WINDOW *,char *,int);
  int waddstr (WINDOW *,char *);
  int wattron (WINDOW *, int);
  int wattroff (WINDOW *, int);
  int wattrset (WINDOW *, int);
  int wattr_get (WINDOW *, attr_t *, short *, void *);
  int wattr_on (WINDOW *, attr_t, void *);
  int wattr_off (WINDOW *, attr_t, void *);
  int wattr_set (WINDOW *, attr_t, short, void *);
  int wbkgd (WINDOW *, chtype);
  void wbkgdset (WINDOW *,chtype);
  int wborder (WINDOW *,chtype,chtype,chtype,chtype,chtype,chtype,chtype,chtype);
  int wchgat (WINDOW *, int, attr_t, short, void *);
  int wclear (WINDOW *);
  int wclrtobot (WINDOW *);
  int wclrtoeol (WINDOW *);
  int wcolor_set (WINDOW*,short,void*);
  void wcursyncup (WINDOW *);
  int wdelch (WINDOW *);
  int wdeleteln (WINDOW *);
  int wechochar (WINDOW *, chtype);
  int werase (WINDOW *);
  int wgetch (WINDOW *);
  int wgetnstr (WINDOW *,char *,int);
  int wgetstr (WINDOW *, char *);
  int whline (WINDOW *, chtype, int);
  chtype winch (WINDOW *);
  int winchnstr (WINDOW *, chtype *, int);
  int winchstr (WINDOW *, chtype *);
  int winnstr (WINDOW *, char *, int);
  int winsch (WINDOW *, chtype);
  int winsdelln (WINDOW *,int);
  int winsertln (WINDOW *);
  int winsnstr (WINDOW *, char *,int);
  int winsstr (WINDOW *, char *);
  int winstr (WINDOW *, char *);
  int wmove (WINDOW *,int,int);
  int wnoutrefresh (WINDOW *);
  int wprintw (WINDOW *, char *, ...);
  int wredrawln (WINDOW *,int,int);
  int wrefresh (WINDOW *);
  int wscanw (WINDOW *, char *,...);
  int wscrl (WINDOW *,int);
  int wsetscrreg (WINDOW *,int,int);
  int wstandout (WINDOW *);
  int wstandend (WINDOW *);
  void wsyncdown (WINDOW *);
  void wsyncup (WINDOW *);
  void wtimeout (WINDOW *,int);
  int wtouchln (WINDOW *,int,int,int);
  int wvline (WINDOW *,chtype,int);

/*
 * These functions are not in X/Open, but we use them in macro definitions:
 */
  int getcurx (WINDOW *);
  int getcury (WINDOW *);
  int getbegx (WINDOW *);
  int getbegy (WINDOW *);
  int getmaxx (WINDOW *);
  int getmaxy (WINDOW *);
  int getparx (WINDOW *);
  int getpary (WINDOW *);

  version (NCURSES) {
    // Functions that do not belong to XSI CURSES, part of NCURSES library.
    bool is_term_resized(int, int);
    char* keybound(int, int);
    char* curses_version(void);
    int assume_default_colors(int, int);
    int define_key(char *, int);
    int key_defined(char *);
    int keyok(int, bool);
    int resize_term(int, int);
    int resizeterm(int, int);
    int use_default_colors(void);
    int use_extended_names(bool);
    int use_legacy_coding(int);
    int wresize(WINDOW*, int, int);
    void nofilter(void);
  } // NCURSES version

  __gshared WINDOW* stdscr;
  __gshared int LINES;
  __gshared int COLS;
  __gshared int TABSIZE;
  __gshared int ESCDELAY;       /// ESC expire time in milliseconds
} // extern(C)

// ..................................... Alternate character set constants ....
// VT100 symbols
chtype ACS_ULCORNER; /* upper left corner */
chtype ACS_LLCORNER; /* lower left corner */
chtype ACS_URCORNER; /* upper right corner */
chtype ACS_LRCORNER; /* lower right corner */
chtype ACS_LTEE;     /* tee pointing right */
chtype ACS_RTEE;     /* tee pointing left */
chtype ACS_BTEE;     /* tee pointing up */
chtype ACS_TTEE;     /* tee pointing down */
chtype ACS_HLINE;    /* horizontal line */
chtype ACS_VLINE;    /* vertical line */
chtype ACS_PLUS;     /* large plus or crossover */
chtype ACS_S1;       /* scan line 1 */
chtype ACS_S9;       /* scan line 9 */
chtype ACS_DIAMOND;  /* diamond */
chtype ACS_CKBOARD;  /* checker board (stipple) */
chtype ACS_DEGREE;   /* degree symbol */
chtype ACS_PLMINUS;  /* plus/minus */
chtype ACS_BULLET;   /* bullet */

// Teletype 5410v1 symbols
chtype ACS_LARROW;   /* arrow pointing left */
chtype ACS_RARROW;   /* arrow pointing right */
chtype ACS_DARROW;   /* arrow pointing down */
chtype ACS_UARROW;   /* arrow pointing up */
chtype ACS_BOARD;    /* board of squares */
chtype ACS_LANTERN;  /* lantern symbol */
chtype ACS_BLOCK;    /* solid square block */

// Undocumented symbols, commonly found on System V systems.
chtype ACS_S3;       /* scan line 3 */
chtype ACS_S7;       /* scan line 7 */
chtype ACS_LEQUAL;   /* less/equal */
chtype ACS_GEQUAL;   /* greater/equal */
chtype ACS_PI;       /* Pi */
chtype ACS_NEQUAL;   /* not equal */
chtype ACS_STERLING; /* UK pound sign */

/** Line drawing symbols.
 * Format: ACS_trbl                        Each can be:
 *             |||`- left                  B - blank
 *             || `- bottom                S - single
 *             | `-- right                 D - double
 *              `--- top                   T - thick
 * Please note that we have defined just B-lank and S-ingle line drawing
 * symbols here.
 */
chtype ACS_BSSB;
chtype ACS_SSBB;
chtype ACS_BBSS;
chtype ACS_SBBS;
chtype ACS_SBSS;
chtype ACS_SSSB;
chtype ACS_SSBS;
chtype ACS_BSSS;
chtype ACS_BSBS;
chtype ACS_SBSB;
chtype ACS_SSSS;

// ............................................................ KEY macros ....
/*
 * Pseudo-character tokens outside ASCII range.  The curses wgetch() function
 * will return any given one of these only if the corresponding k- capability
 * is defined in your terminal's terminfo entry.
 *
 * Some keys (KEY_A1, etc) are arranged like this:
 *  a1     up    a3
 *  left   b2    right
 *  c1     down  c3
 *
 * A few key codes do not depend upon the terminfo entry.
 */
const ushort KEY_CODE_YES = 0400;    /* A wchar_t contains a key code */
const ushort KEY_MIN =  0401;    /* Minimum curses key */
const ushort KEY_BREAK = 0401;    /* Break key (unreliable) */
const ushort KEY_SRESET = 0530;    /* Soft (partial) reset (unreliable) */
const ushort KEY_RESET = 0531;    /* Reset or hard reset (unreliable) */

const ushort KEY_DOWN = 0402;    /* down-arrow key */
const ushort KEY_UP   = 0403;    /* up-arrow key */
const ushort KEY_LEFT = 0404;    /* left-arrow key */
const ushort KEY_RIGHT= 0405;    /* right-arrow key */
const ushort KEY_HOME = 0406;    /* home key */
const ushort KEY_BACKSPACE= 0407;    /* backspace key */
const ushort KEY_F0   = 0410;    /* Function keys.  Space for 64 */
template KEY_F(ubyte key_id_arg)
{
  const ushort KEY_F = KEY_F0 + key_id_arg;
} // KEY_F() template function
const ushort KEY_DL   = 0510;    /* delete-line key */
const ushort KEY_IL   = 0511;    /* insert-line key */
const ushort KEY_DC   = 0512;    /* delete-character key */
const ushort KEY_IC   = 0513;    /* insert-character key */
const ushort KEY_EIC  = 0514;    /* sent by rmir or smir in insert mode */
const ushort KEY_CLEAR= 0515;    /* clear-screen or erase key */
const ushort KEY_EOS  = 0516;    /* clear-to-end-of-screen key */
const ushort KEY_EOL  = 0517;    /* clear-to-end-of-line key */
const ushort KEY_SF   = 0520;    /* scroll-forward key */
const ushort KEY_SR   = 0521;    /* scroll-backward key */
const ushort KEY_NPAGE= 0522;    /* next-page key */
const ushort KEY_PPAGE= 0523;    /* previous-page key */
const ushort KEY_STAB = 0524;    /* set-tab key */
const ushort KEY_CTAB = 0525;    /* clear-tab key */
const ushort KEY_CATAB= 0526;    /* clear-all-tabs key */
const ushort KEY_ENTER= 0527;    /* enter/send key */
const ushort KEY_PRINT= 0532;    /* print key */
const ushort KEY_LL   = 0533;    /* lower-left key (home down) */
const ushort KEY_A1   = 0534;    /* upper left of keypad */
const ushort KEY_A3   = 0535;    /* upper right of keypad */
const ushort KEY_B2   = 0536;    /* center of keypad */
const ushort KEY_C1   = 0537;    /* lower left of keypad */
const ushort KEY_C3   = 0540;    /* lower right of keypad */
const ushort KEY_BTAB = 0541;    /* back-tab key */
const ushort KEY_BEG  = 0542;    /* begin key */
const ushort KEY_CANCEL = 0543;    /* cancel key */
const ushort KEY_CLOSE= 0544;    /* close key */
const ushort KEY_COMMAND= 0545;    /* command key */
const ushort KEY_COPY = 0546;    /* copy key */
const ushort KEY_CREATE = 0547;    /* create key */
const ushort KEY_END  = 0550;    /* end key */
const ushort KEY_EXIT = 0551;    /* exit key */
const ushort KEY_FIND = 0552;    /* find key */
const ushort KEY_HELP = 0553;    /* help key */
const ushort KEY_MARK = 0554;    /* mark key */
const ushort KEY_MESSAGE= 0555;    /* message key */
const ushort KEY_MOVE = 0556;    /* move key */
const ushort KEY_NEXT = 0557;    /* next key */
const ushort KEY_OPEN = 0560;    /* open key */
const ushort KEY_OPTIONS= 0561;    /* options key */
const ushort KEY_PREVIOUS = 0562;    /* previous key */
const ushort KEY_REDO = 0563;    /* redo key */
const ushort KEY_REFERENCE= 0564;    /* reference key */
const ushort KEY_REFRESH= 0565;    /* refresh key */
const ushort KEY_REPLACE= 0566;    /* replace key */
const ushort KEY_RESTART= 0567;    /* restart key */
const ushort KEY_RESUME = 0570;    /* resume key */
const ushort KEY_SAVE = 0571;    /* save key */
const ushort KEY_SBEG = 0572;    /* shifted begin key */
const ushort KEY_SCANCEL= 0573;    /* shifted cancel key */
const ushort KEY_SCOMMAND = 0574;    /* shifted command key */
const ushort KEY_SCOPY= 0575;    /* shifted copy key */
const ushort KEY_SCREATE= 0576;    /* shifted create key */
const ushort KEY_SDC  = 0577;    /* shifted delete-character key */
const ushort KEY_SDL  = 0600;    /* shifted delete-line key */
const ushort KEY_SELECT = 0601;    /* select key */
const ushort KEY_SEND = 0602;    /* shifted end key */
const ushort KEY_SEOL = 0603;    /* shifted clear-to-end-of-line key */
const ushort KEY_SEXIT= 0604;    /* shifted exit key */
const ushort KEY_SFIND= 0605;    /* shifted find key */
const ushort KEY_SHELP= 0606;    /* shifted help key */
const ushort KEY_SHOME= 0607;    /* shifted home key */
const ushort KEY_SIC  = 0610;    /* shifted insert-character key */
const ushort KEY_SLEFT= 0611;    /* shifted left-arrow key */
const ushort KEY_SMESSAGE = 0612;    /* shifted message key */
const ushort KEY_SMOVE= 0613;    /* shifted move key */
const ushort KEY_SNEXT= 0614;    /* shifted next key */
const ushort KEY_SOPTIONS = 0615;    /* shifted options key */
const ushort KEY_SPREVIOUS= 0616;    /* shifted previous key */
const ushort KEY_SPRINT = 0617;    /* shifted print key */
const ushort KEY_SREDO= 0620;    /* shifted redo key */
const ushort KEY_SREPLACE = 0621;    /* shifted replace key */
const ushort KEY_SRIGHT = 0622;    /* shifted right-arrow key */
const ushort KEY_SRSUME = 0623;    /* shifted resume key */
const ushort KEY_SSAVE= 0624;    /* shifted save key */
const ushort KEY_SSUSPEND = 0625;    /* shifted suspend key */
const ushort KEY_SUNDO= 0626;    /* shifted undo key */
const ushort KEY_SUSPEND= 0627;    /* suspend key */
const ushort KEY_UNDO = 0630;    /* undo key */
const ushort KEY_MOUSE= 0631;    /* Mouse event has occurred */
const ushort KEY_RESIZE = 0632;    /* Terminal resize event */
const ushort KEY_EVENT= 0633;    /* We were interrupted by an event */

const ushort KEY_MAX =  0777;    /* Maximum key value is 0633 */

/**
 * Initialises dl.c.curses.curses module.
 * TODO: Can we call this function upon initialization of the module, somehow?
 */
void init_() {
  /*
   * Now we are going to update common "alternate characters set" 'constants'.
   */
  ACS_ULCORNER = acs_map['l']; /* upper left corner */
  ACS_LLCORNER	= acs_map['m']; /* lower left corner */
  ACS_URCORNER	= acs_map['k']; /* upper right corner */
  ACS_LRCORNER	= acs_map['j']; /* lower right corner */
  ACS_LTEE	= acs_map['t']; /* tee pointing right */
  ACS_RTEE	= acs_map['u']; /* tee pointing left */
  ACS_BTEE	= acs_map['v']; /* tee pointing up */
  ACS_TTEE	= acs_map['w']; /* tee pointing down */
  ACS_HLINE	= acs_map['q']; /* horizontal line */
  ACS_VLINE	= acs_map['x']; /* vertical line */
  ACS_PLUS	= acs_map['n']; /* large plus or crossover */
  ACS_S1		= acs_map['o']; /* scan line 1 */
  ACS_S9		= acs_map['s']; /* scan line 9 */
  ACS_DIAMOND	= acs_map['`']; /* diamond */
  ACS_CKBOARD	= acs_map['a']; /* checker board (stipple) */
  ACS_DEGREE	= acs_map['f']; /* degree symbol */
  ACS_PLMINUS	= acs_map['g']; /* plus/minus */
  ACS_BULLET	= acs_map['~']; /* bullet */

  ACS_LARROW	= acs_map[',']; /* arrow pointing left */
  ACS_RARROW	= acs_map['+']; /* arrow pointing right */
  ACS_DARROW	= acs_map['.']; /* arrow pointing down */
  ACS_UARROW	= acs_map['-']; /* arrow pointing up */
  ACS_BOARD	= acs_map['h']; /* board of squares */
  ACS_LANTERN	= acs_map['i']; /* lantern symbol */
  ACS_BLOCK	= acs_map['0']; /* solid square block */

  ACS_S3		= acs_map['p']; /* scan line 3 */
  ACS_S7		= acs_map['r']; /* scan line 7 */
  ACS_LEQUAL	= acs_map['y']; /* less/equal */
  ACS_GEQUAL	= acs_map['z']; /* greater/equal */
  ACS_PI		= acs_map['{']; /* Pi */
  ACS_NEQUAL	= acs_map['|']; /* not equal */
  ACS_STERLING	= acs_map['}']; /* UK pound sign */

  ACS_BSSB	= ACS_ULCORNER;
  ACS_SSBB	= ACS_LLCORNER;
  ACS_BBSS	= ACS_URCORNER;
  ACS_SBBS	= ACS_LRCORNER;
  ACS_SBSS	= ACS_RTEE;
  ACS_SSSB	= ACS_LTEE;
  ACS_SSBS	= ACS_BTEE;
  ACS_BSSS	= ACS_TTEE;
  ACS_BSBS	= ACS_HLINE;
  ACS_SBSB	= ACS_VLINE;
  ACS_SSSS	= ACS_PLUS;
} // init_() function
