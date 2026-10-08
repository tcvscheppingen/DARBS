/* See LICENSE file for copyright and license details. */

/* Constants */
#define TERMINAL "st"
#define TERMCLASS "St"
#define BROWSER "librewolf"
#define FILEMANAGER "thunar"

/* appearance */
static const unsigned int borderpx  = 3;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
/* Same gaps as the sway rice: 10px between windows, 30px at the left and
 * right edges and 10px at the top and bottom */
static const unsigned int gappih    = 10;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 10;       /* vert inner gap between windows */
static const unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 30;       /* vert outer gap between windows and screen edge */
static       int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "JetBrainsMono Nerd Font:size=10", "Noto Color Emoji:pixelsize=12:antialias=true:autohint=true" };

/* Gruvbox palette */
static const char bg0[]             = "#282828";
static const char bg1[]             = "#3c3836";
static const char fg[]              = "#ebdbb2";
static const char dyellow[]         = "#d79921";
static const char *colors[][3]      = {
	/*               fg   bg       border   */
	[SchemeNorm] = { fg,  bg0,     bg1     },
	[SchemeSel]  = { bg0, dyellow, dyellow },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance     title           tags mask  isfloating  isterminal  noswallow  monitor */
	{ TERMCLASS,  NULL,        NULL,           0,         0,          1,          0,         -1 },
	{ NULL,       NULL,        "Event Tester", 0,         0,          0,          1,         -1 }, /* xev */
	{ TERMCLASS,  "floatterm", NULL,           0,         1,          1,          0,         -1 },
	{ TERMCLASS,  "bg",        NULL,           1 << 7,    0,          1,          0,         -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
static const int refreshrate = 120;  /* refresh rate (per second) for client move/resize */

#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },                   /* Default: master on left, slaves on right */
	{ "TTT",      bstack },                 /* Master on top, slaves on bottom */

	{ "[@]",      spiral },                 /* Fibonacci spiral */
	{ "[\\]",     dwindle },                /* Decreasing in size right and leftward */

	{ "[D]",      deck },                   /* Master on left, slaves in monocle-like mode on right */
	{ "[M]",      monocle },                /* All windows on top of each other */

	{ "|M|",      centeredmaster },         /* Master in middle, slaves on sides */
	{ ">M>",      centeredfloatingmaster }, /* Same but master floats */

	{ "><>",      NULL },                   /* no layout function means floating behavior */
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },
#define STACKKEYS(MOD,ACTION) \
	{ MOD,                          XK_j,     ACTION##stack,  {.i = INC(+1) } }, \
	{ MOD,                          XK_k,     ACTION##stack,  {.i = INC(-1) } }, \
	{ MOD,                          XK_v,     ACTION##stack,  {.i = 0 } },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
/* dmenu takes its font and colors from its own config.h */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, NULL };
static const char *termcmd[]  = { TERMINAL, NULL };

#include <X11/XF86keysym.h>

/* Luke Smith's key bindings (https://github.com/LukeSmithxyz/dwm), limited
 * to stock dwm, vanitygaps, swallow and stacker, and to the programs of this
 * rice */
static const Key keys[] = {
	/* modifier                     key              function            argument */
	STACKKEYS(MODKEY,                                focus)
	STACKKEYS(MODKEY|ShiftMask,                      push)
	TAGKEYS(                        XK_1,                                0)
	TAGKEYS(                        XK_2,                                1)
	TAGKEYS(                        XK_3,                                2)
	TAGKEYS(                        XK_4,                                3)
	TAGKEYS(                        XK_5,                                4)
	TAGKEYS(                        XK_6,                                5)
	TAGKEYS(                        XK_7,                                6)
	TAGKEYS(                        XK_8,                                7)
	TAGKEYS(                        XK_9,                                8)
	{ MODKEY,                       XK_0,            view,               {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,            tag,                {.ui = ~0 } },
	{ MODKEY,                       XK_minus,        spawn,              SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") },
	{ MODKEY|ShiftMask,             XK_minus,        spawn,              SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 15%-") },
	{ MODKEY,                       XK_equal,        spawn,              SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") },
	{ MODKEY|ShiftMask,             XK_equal,        spawn,              SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 15%+") },
	{ MODKEY,                       XK_BackSpace,    spawn,              {.v = (const char*[]){ "sysact", NULL } } },
	{ MODKEY|ShiftMask,             XK_BackSpace,    spawn,              {.v = (const char*[]){ "sysact", NULL } } },

	{ MODKEY,                       XK_Tab,          view,               {0} },
	{ MODKEY,                       XK_q,            killclient,         {0} },
	{ MODKEY|ShiftMask,             XK_q,            spawn,              {.v = (const char*[]){ "sysact", NULL } } },
	{ MODKEY,                       XK_w,            spawn,              {.v = (const char*[]){ BROWSER, NULL } } },
	{ MODKEY|ShiftMask,             XK_w,            spawn,              {.v = (const char*[]){ TERMINAL, "-e", "nmtui", NULL } } },
	{ MODKEY,                       XK_r,            spawn,              {.v = (const char*[]){ FILEMANAGER, NULL } } },
	{ MODKEY,                       XK_t,            setlayout,          {.v = &layouts[0]} }, /* tile */
	{ MODKEY|ShiftMask,             XK_t,            setlayout,          {.v = &layouts[1]} }, /* bstack */
	{ MODKEY,                       XK_y,            setlayout,          {.v = &layouts[2]} }, /* spiral */
	{ MODKEY|ShiftMask,             XK_y,            setlayout,          {.v = &layouts[3]} }, /* dwindle */
	{ MODKEY,                       XK_u,            setlayout,          {.v = &layouts[4]} }, /* deck */
	{ MODKEY|ShiftMask,             XK_u,            setlayout,          {.v = &layouts[5]} }, /* monocle */
	{ MODKEY,                       XK_i,            setlayout,          {.v = &layouts[6]} }, /* centeredmaster */
	{ MODKEY|ShiftMask,             XK_i,            setlayout,          {.v = &layouts[7]} }, /* centeredfloatingmaster */
	{ MODKEY,                       XK_o,            incnmaster,         {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_o,            incnmaster,         {.i = -1 } },
	{ MODKEY,                       XK_backslash,    view,               {0} },

	{ MODKEY,                       XK_a,            togglegaps,         {0} },
	{ MODKEY|ShiftMask,             XK_a,            defaultgaps,        {0} },
	{ MODKEY,                       XK_d,            spawn,              {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_f,            setlayout,          {.v = &layouts[8]} }, /* floating */
	{ MODKEY,                       XK_h,            setmfact,           {.f = -0.05} },
	{ MODKEY,                       XK_l,            setmfact,           {.f = +0.05} },
	{ MODKEY,                       XK_Return,       spawn,              {.v = termcmd } },

	{ MODKEY,                       XK_z,            incrgaps,           {.i = +3 } },
	{ MODKEY,                       XK_x,            incrgaps,           {.i = -3 } },
	{ MODKEY,                       XK_b,            togglebar,          {0} },
	{ MODKEY|ShiftMask,             XK_m,            spawn,              SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") },

	{ MODKEY,                       XK_Left,         focusmon,           {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_Left,         tagmon,             {.i = -1 } },
	{ MODKEY,                       XK_Right,        focusmon,           {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_Right,        tagmon,             {.i = +1 } },

	{ MODKEY,                       XK_F3,           spawn,              {.v = (const char*[]){ "displayselect", NULL } } },
	{ MODKEY,                       XK_space,        zoom,               {0} },
	{ MODKEY|ShiftMask,             XK_space,        togglefloating,     {0} },

	{ 0,                            XK_Print,        spawn,              SHCMD("maim pic-full-$(date '+%y%m%d-%H%M-%S').png") },
	{ ShiftMask,                    XK_Print,        spawn,              {.v = (const char*[]){ "maimpick", NULL } } },
	{ MODKEY,                       XK_Print,        spawn,              {.v = (const char*[]){ "dmenurecord", NULL } } },
	{ MODKEY|ShiftMask,             XK_Print,        spawn,              {.v = (const char*[]){ "dmenurecord", "kill", NULL } } },
	{ MODKEY,                       XK_Delete,       spawn,              {.v = (const char*[]){ "dmenurecord", "kill", NULL } } },

	{ 0, XF86XK_AudioMute,                           spawn,              SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") },
	{ 0, XF86XK_AudioRaiseVolume,                    spawn,              SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%- && wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+") },
	{ 0, XF86XK_AudioLowerVolume,                    spawn,              SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%+ && wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-") },
	{ 0, XF86XK_AudioMicMute,                        spawn,              SHCMD("pactl set-source-mute @DEFAULT_SOURCE@ toggle") },
	{ 0, XF86XK_AudioPrev,                           spawn,              {.v = (const char*[]){ "playerctl", "previous", NULL } } },
	{ 0, XF86XK_AudioNext,                           spawn,              {.v = (const char*[]){ "playerctl", "next", NULL } } },
	{ 0, XF86XK_AudioPlay,                           spawn,              {.v = (const char*[]){ "playerctl", "play-pause", NULL } } },
	{ 0, XF86XK_MonBrightnessUp,                     spawn,              {.v = (const char*[]){ "brightnessctl", "set", "5%+", NULL } } },
	{ 0, XF86XK_MonBrightnessDown,                   spawn,              {.v = (const char*[]){ "brightnessctl", "set", "5%-", NULL } } },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        defaultgaps,    {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkClientWin,         MODKEY,         Button4,        incrgaps,       {.i = +1} },
	{ ClkClientWin,         MODKEY,         Button5,        incrgaps,       {.i = -1} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
	{ ClkRootWin,           0,              Button2,        togglebar,      {0} },
};
