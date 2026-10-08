/* Blocks of the status bar. dwm's statuscmd patch sends clicks on a block to
 * its script with BLOCK_BUTTON set to the mouse button. "pkill -RTMIN+<signal>
 * dwmblocks" updates a block right away. Recompile with make after editing. */
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"",	"sb-network",	5,	4},
	{"",	"sb-recording",	0,	9},
	{"",	"sb-volume",	5,	10},
	{"",	"sb-battery",	5,	3},
	{"",	"sb-memory",	5,	14},
	{"",	"sb-clock",	1,	1},
};

/* Sets delimiter between status commands. NULL character ('\0') means no delimiter. */
static char *delim = " | ";
