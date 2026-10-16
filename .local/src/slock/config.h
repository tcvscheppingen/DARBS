/* user and group to drop privileges to */
static const char *user  = "nobody";
static const char *group = "nobody";

static const char *colorname[NUMCOLS] = {
	[INIT] =   "#151515",   /* after initialization */
	[INPUT] =  "#3d7ab8",   /* during input */
	[FAILED] = "#c25d5d",   /* wrong password */
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;
