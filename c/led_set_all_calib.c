/*-----------------------------------------------------------
-- led_set_all_calib.c
--
-- All LED, MFPI, calibration coefficients for spectral camera
-- in C source file format
--
-- cl led_set_all_calib.c
--
-- Copyright: Daniel Tisza, 2022, GPLv3 or later
-----------------------------------------------------------*/


/*------------------------------------------------------------------------------
 * Includes
 *----------------------------------------------------------------------------*/
#include <stdio.h>


/*------------------------------------------------------------------------------
 * Definitions
 *----------------------------------------------------------------------------*/

/*
 * 237 raw CFA images
 * 69 with two peak wavelengths
 * 306 calibrated images
 */

#define CALIBROW_COLS		13
#define CALIBROW_COUNT		237

typedef double CalibRowType[CALIBROW_COLS];


/*------------------------------------------------------------------------------
 * Global variables
 *----------------------------------------------------------------------------*/

/*
 * ledset	LED lighting setting to use (0=Off)
 *
 * Npeaks	Number of FPI orders that are transmitted through the
 *			used band filter infront of the hyperspectral imager
 *
 * SP1 voltage	FPI controller Set Point 1 voltage
 *
 * PeakWL1	The shortest center wavelength of the wavelength that is transmitted
 *			through the optical system for a given FPI set point
 *
 * PeakWL2	The 2nd shortest center wavelength of the wavelength that is
 * 			transmitted through the optical system for a given FPI set point
 * 
 * Sinv11	Calibration coefficient of red pixels used to multiply the
 *			normalized pixel signal to get the calibrated spectral signal for PeakWL1
 * Sinv12	Calibration coefficient of green pixels used to multiply the
 * 			normalized pixel signal to get the calibrated spectral signal for PeakWL1
 * Sinv13	Calibration coefficient of blue pixels used to multiply the 
 * 			normalized pixel signal to get the calibrated spectral signal for PeakWL1
 * 
 * Sinv21	Calibration coefficient of red pixels used to multiply the
 * 			normalized pixel signal to get the calibrated spectral signal for PeakWL2
 * Sinv22	Calibration coefficient of green pixels used to multiply the
 * 			normalized pixel signal to get the calibrated spectral signal for PeakWL2
 * Sinv23	Calibration coefficient of blue pixels used to multiply the
 * 			normalized pixel signal to get the calibrated spectral signal for PeakWL3
 * 
 * FWHM1	Spectral resolution of the PeakWL1 @ FWHM
 * FWHM2	Spectral resolution of the PeakWL2 @ FWHM
 *
 */
const CalibRowType calibRows[CALIBROW_COUNT] = {

/*	ledset	Npeaks	SP1		PeakWL1				PeakWL2				Sinv11				Sinv12				Sinv13				Sinv21				Sinv22			Sinv23			FWHM1				FWHM2				*/
{	1,		2,		53204,	542.8327583,		701.3626464,		-0.420617448,		0.611790438,		0.194467613,		1.732237891,		-0.341320306,	0.496859231,	22.03297271,		28.73682659		},
{	1,		2,		53127,	543.66097,			702.6988306,		-0.419289634,		0.619177961,		0.157608083,		1.739098182,		-0.353827542,	0.57641956,		22.36907205,		27.41629179		},
{	1,		2,		53047,	544.6850823,		704.0215069,		-0.439669591,		0.651841214,		0.199886125,		1.776956477,		-0.360874023,	0.524324152,	21.71155616,		26.26978143		},
{	1,		2,		52971,	545.4860666,		705.099743,			-0.434260493,		0.66039508,			0.184689121,		1.881310176,		-0.395707629,	0.593819092,	21.93786033,		25.23779324		},
{	1,		2,		52894,	546.5008668,		705.9499835,		-0.413590167,		0.675985085,		0.087895082,		1.858546352,		-0.430927109,	0.804798879,	21.40376594,		23.87933246		},
{	1,		2,		52818,	547.275186,			706.8020916,		-0.396391839,		0.694799281,		-0.005300681,		1.847016205,		-0.467610561,	1.017436451,	21.53006108,		22.89077043		},
{	1,		2,		52735,	548.3117179,		707.2102387,		-0.384476856,		0.704905408,		-0.051138376,		1.983483038,		-0.528430012,	1.21486645,		21.08627216,		21.47977408		},
{	1,		2,		52670,	548.8607007,		707.5635196,		-0.376631921,		0.712891793,		-0.088670093,		1.994937589,		-0.550875404,	1.322077557,	21.11222389,		20.78657171		},
{	1,		2,		52576,	549.9926585,		708.4738085,		-0.325186609,		0.754630773,		-0.331289161,		1.929434309,		-0.652832584,	1.944027905,	20.71710414,		19.30825524		},
{	1,		2,		52482,	550.812515,			709.4203849,		-0.302574377,		0.775344314,		-0.435149286,		2.118800852,		-0.780417735,	2.475380289,	20.8238033,			17.92178563		},
{	1,		2,		52386,	551.9493336,		709.8062611,		-0.272240304,		0.806145758,		-0.59349695,		2.124757809,		-0.878705922,	3.019504799,	20.44296034,		16.79599902		},
{	1,		2,		52275,	552.8525817,		710.1310492,		-0.243232915,		0.835636167,		-0.74232312,		2.170792156,		-0.99849105,	3.636918334,	20.67959555,		15.83229797		},
{	2,		2,		53895,	533.8275323,		687.9319591,		-0.324303817,		0.5930675,			0.310029492,		1.312390885,		-0.257394663,	0.226933728,	23.63863743,		32.06504173		},
{	2,		2,		53806,	534.9730097,		689.8544049,		-0.345609621,		0.593682654,		0.295413526,		1.372514853,		-0.263853826,	0.255769589,	23.84791648,		32.26609169		},
{	2,		2,		53733,	536.1788599,		691.3466885,		-0.355440478,		0.597538478,		0.269893399,		1.41356075,			-0.276349148,	0.304661227,	23.39300812,		32.60739618		},
{	2,		2,		53670,	536.9797421,		692.7844733,		-0.370329825,		0.604921011,		0.186395584,		1.444572574,		-0.291641137,	0.4534488,		23.46318322,		32.36878523		},
{	2,		2,		53619,	537.5200703,		693.6197061,		-0.37370688,		0.602800449,		0.227709549,		1.472002566,		-0.291360058,	0.385973591,	23.58509383,		32.56657709		},
{	2,		2,		53576,	538.293304,			694.5982185,		-0.378591224,		0.609829294,		0.158960946,		1.483803453,		-0.305942965,	0.510450459,	22.94145618,		32.0228617		},
{	2,		2,		53539,	538.6529211,		695.1991202,		-0.388303131,		0.603345923,		0.224077897,		1.524705442,		-0.298242228,	0.398965883,	22.88982405,		32.12404355		},
{	2,		2,		53506,	539.0064478,		695.9738452,		-0.388450082,		0.608261345,		0.1914733,			1.522385141,		-0.30598676,	0.458571095,	22.98017146,		31.74762117		},
{	2,		2,		53474,	539.3791577,		696.5177541,		-0.3875841,			0.613080685,		0.144686033,		1.529203577,		-0.317640939,	0.546836463,	23.00796211,		31.47537105		},
{	2,		2,		53443,	539.9821438,		697.0142294,		-0.397974801,		0.607036573,		0.206596639,		1.567710242,		-0.310360332,	0.437944091,	22.53372665,		31.5311146		},
{	2,		2,		35239,	539.9958919,		660.5024267,		-0.22120096,		0.699073051,		0.255168773,		1.253786491,		-0.276796447,	0.461497047,	18.15753304,		21.44710441		},
{	2,		2,		53406,	540.3298403,		697.8388904,		-0.400782848,		0.609822392,		0.176148385,		1.579527927,		-0.316976905,	0.49685704,		22.46295748,		30.99636618		},
{	2,		2,		53369,	540.780494,			698.4397829,		-0.39784357,		0.618078569,		0.112674424,		1.575424122,		-0.333021649,	0.616397963,	22.43929029,		30.8534609		},
{	2,		2,		53324,	541.2738618,		699.2120027,		-0.408535215,		0.61199781,			0.190053528,		1.620428351,		-0.3235071,		0.48022235,		22.52783069,		30.59271222		},
{	2,		2,		34667,	541.391868,			662.5460038,		-0.199377854,		0.733255365,		0.052227215,		1.23087071,			-0.336696146,	0.807973736,	18.50644486,		21.56695443		},
{	2,		2,		53267,	542.1821703,		700.3681421,		-0.408204177,		0.617500584,		0.139364862,		1.672917218,		-0.345811714,	0.595225564,	22.08525082,		29.50697421		},
{	2,		2,		34141,	543.0093247,		664.4708461,		-0.166157354,		0.778872283,		-0.211700126,		1.187492424,		-0.414208632,	1.264681439,	18.1248182,			21.69888423		},
{	2,		2,		33519,	544.7940893,		666.6187462,		-0.153851881,		0.864785372,		-0.444382519,		1.164692475,		-0.475456733,	1.632487652,	17.90985035,		21.90610687		},
{	2,		2,		32902,	546.5200869,		668.722508,			-0.093300786,		0.934831269,		-0.855062827,		1.023951667,		-0.557492551,	2.195672914,	17.74758653,		22.05913037		},
{	2,		2,		32410,	547.9435618,		670.419621,			-0.033097435,		1.002178578,		-1.246062,			0.941021878,		-0.658921908,	2.815570398,	17.5773986,			22.00005834		},
{	2,		2,		31672,	549.4620166,		672.7667141,		0.017518226,		1.002166172,		-1.505028699,		0.877029686,		-0.751111057,	3.394600247,	18.0402813,			22.09299839		},
{	2,		2,		30938,	551.1910404,		675.0399944,		0.069139698,		1.132277758,		-1.967772378,		0.813603037,		-0.844492166,	3.990419169,	17.68457178,		22.19130381		},
{	2,		2,		30333,	552.6366519,		676.91402,			0.079436604,		1.158397332,		-2.089442114,		0.80718595,			-0.872998389,	4.184617548,	17.27528266,		22.10466439		},
{	2,		2,		29619,	554.2690625,		679.0219539,		0.144598642,		1.241789639,		-2.541063116,		0.721564411,		-0.976267755,	4.877452432,	17.15621261,		22.29731758		},
{	2,		2,		28789,	556.0636503,		681.4161131,		0.190028799,		1.317682581,		-2.90396841,		0.668991285,		-1.050895593,	5.387926549,	17.28258829,		22.8268466		},
{	2,		2,		28011,	557.3879727,		683.9085069,		0.229279019,		1.30453368,			-3.098656837,		0.600099699,		-1.134118261,	5.967540867,	18.27741671,		22.59999916		},
{	2,		2,		27229,	559.0412604,		686.1145488,		0.308763567,		1.395051531,		-3.598263724,		0.48859329,			-1.241748202,	6.712073308,	18.39933577,		22.99985634		},
{	2,		2,		26226,	561.1021639,		688.8229149,		0.470581047,		1.531389033,		-4.376295675,		0.251355332,		-1.410131219,	7.842757917,	19.1429395,			23.53244884		},
{	2,		2,		25324,	563.0131,			691.2632427,		0.765797335,		1.731729826,		-5.655387877,		-0.192404061,		-1.686438695,	9.73942159,		19.89791872,		23.88416058		},
{	2,		2,		24267,	565.2796907,		694.2103703,		1.047206879,		1.886430335,		-6.555590571,		-0.615740678,		-1.917279742,	11.1753238,		21.35264079,		23.30840474		},
{	2,		2,		23113,	568.2446615,		696.8895468,		0.761277678,		2.097116838,		-6.093937831,		0.775863565,		-1.732996915,	9.306909954,	22.62755506,		23.0986094		},
{	3,		2,		44748,	505.914289,			614.2813052,		-0.398411474,		1.259903596,		1.025911637,		0.752656263,		-0.099247137,	0.020958335,	14.26460175,		22.90707427		},
{	3,		2,		44504,	506.3181366,		615.9095098,		-0.364495855,		1.176188483,		0.92495601,			0.765202521,		-0.106846281,	0.0353548,		15.09912909,		22.79424699		},
{	3,		2,		44248,	506.9382743,		617.3439037,		-0.337134853,		1.104043956,		0.858529224,		0.777804247,		-0.110892649,	0.040502986,	16.23087477,		23.16473398		},
{	3,		2,		43978,	507.8538488,		619.0121786,		-0.30583115,		1.024327027,		0.765801354,		0.791422918,		-0.119844507,	0.057266778,	16.51291242,		22.66593783		},
{	3,		2,		43666,	509.0977574,		620.8469159,		-0.278237594,		0.95500646,			0.689725545,		0.799175554,		-0.12899134,	0.070664975,	17.24490964,		22.21616876		},
{	3,		2,		43342,	510.0601346,		622.6531667,		-0.25327961,		0.879268856,		0.623369971,		0.863335503,		-0.143108203,	0.08429736,		18.37076827,		21.65932089		},
{	3,		2,		43048,	511.3359227,		624.2851672,		-0.23841112,		0.844639486,		0.575735731,		0.878215462,		-0.152799902,	0.103184353,	18.577071,			21.18884467		},
{	3,		2,		42762,	512.6410579,		625.8674836,		-0.230111072,		0.825044037,		0.550044233,		0.893652339,		-0.160007033,	0.114602944,	18.58694859,		20.89169783		},
{	3,		2,		42421,	514.1517243,		627.3012982,		-0.218742338,		0.794242532,		0.518235206,		0.911636412,		-0.168136302,	0.126068664,	18.5484943,			21.42245501		},
{	3,		2,		42156,	515.0403214,		628.6893439,		-0.209994161,		0.773799248,		0.488354141,		0.922498124,		-0.17672722,	0.142210163,	18.59033232,		21.21259358		},
{	3,		2,		41863,	516.3702314,		630.2245406,		-0.206233859,		0.763099194,		0.471907114,		0.941013935,		-0.184051453,	0.153923333,	18.18199287,		21.34892856		},
{	3,		2,		41531,	517.4774165,		631.9369428,		-0.199155531,		0.745591688,		0.443422031,		0.960269196,		-0.194818864,	0.174626587,	18.43740426,		21.66755925		},
{	3,		2,		41210,	518.8027258,		633.305422,			-0.208594081,		0.778111949,		0.456456728,		0.924336074,		-0.189092695,	0.173872734,	17.74874872,		22.46489742		},
{	3,		2,		40906,	520.1131956,		634.8704879,		-0.205648389,		0.770593929,		0.440644935,		0.938567941,		-0.195788953,	0.187599381,	17.41605683,		22.66177639		},
{	3,		2,		40493,	521.3218965,		636.9858183,		-0.204277027,		0.764159078,		0.423347556,		0.961435979,		-0.205272545,	0.205314903,	17.76855614,		23.20648456		},
{	3,		2,		40138,	522.7124801,		638.8372911,		-0.206267446,		0.757505472,		0.428103313,		0.982911128,		-0.206981093,	0.199705025,	17.34963734,		23.44243546		},
{	3,		2,		39769,	524.1720068,		640.7339915,		-0.206939662,		0.751442894,		0.428117697,		1.003590132,		-0.210591874,	0.199031229,	17.33597238,		23.5611704		},
{	3,		2,		39382,	525.2629457,		642.7070415,		-0.210013864,		0.743648145,		0.442603498,		1.024763582,		-0.209515767,	0.180111992,	17.98089024,		23.52230515		},
{	3,		2,		38981,	526.7838709,		644.6991203,		-0.202007413,		0.689389888,		0.434642851,		1.048108521,		-0.206232758,	0.15223784,		18.00666761,		23.42886611		},
{	3,		2,		38481,	528.6216693,		647.0623671,		-0.206961195,		0.680272929,		0.469953264,		1.078039374,		-0.200797368,	0.102352058,	18.47784184,		23.36539267		},
{	3,		2,		38137,	529.6967931,		648.7050781,		-0.213236666,		0.675034929,		0.47800432,			1.096529239,		-0.196707289,	0.090149999,	19.31133749,		22.91851783		},
{	3,		2,		37700,	531.3272678,		650.6954162,		-0.221715215,		0.666835704,		0.504276576,		1.121198561,		-0.189991467,	0.049888885,	19.37791017,		22.56141403		},
{	3,		2,		37248,	533.0034696,		652.6510106,		-0.229195932,		0.66139078,			0.520250693,		1.145198263,		-0.186044243,	0.024930927,	19.3247336,			22.22091543		},
{	3,		2,		36696,	534.9451968,		654.8567183,		-0.233685778,		0.663021357,		0.496830381,		1.238019089,		-0.205350996,	0.062155611,	19.1607787,			21.90090094		},
{	3,		2,		36316,	536.3909141,		656.4559813,		-0.234466942,		0.665681513,		0.470121187,		1.24955705,			-0.214534791,	0.103544163,	18.70811044,		21.60567197		},
{	3,		2,		35736,	538.3231452,		658.6319132,		-0.233277683,		0.676217505,		0.395326711,		1.261745039,		-0.236210482,	0.22642189,		18.400552,			21.47612569		},
{	3,		1,		52164,	554.0473012,		0,					-0.167038819,		0.897291038,		-1.106291748,		0,					0,				0,				20.36692413,		0				},
{	3,		1,		52064,	554.8201114,		0,					-0.116083144,		0.941280185,		-1.354217723,		0,					0,				0,				20.73087834,		0				},
{	3,		1,		51931,	556.2243226,		0,					0.015262253,		1.043953004,		-1.983732647,		0,					0,				0,				20.72875655,		0				},
{	3,		1,		51811,	557.1621125,		0,					0.230499789,		1.189587697,		-2.958302516,		0,					0,				0,				21.34865939,		0				},
{	3,		1,		51680,	558.5611892,		0,					0.382084013,		1.305286442,		-3.673752276,		0,					0,				0,				21.60315428,		0				},
{	3,		1,		51545,	559.946926,			0,					0.679889519,		1.419721666,		-4.845915769,		0,					0,				0,				22.17152035,		0				},
{	3,		1,		51402,	561.2668276,		0,					0.86484934,			1.533626044,		-5.608722012,		0,					0,				0,				23.48824731,		0				},
{	3,		1,		51220,	563.2522566,		0,					0.894320749,		1.558092816,		-5.713358528,		0,					0,				0,				25.53618211,		0				},
{	3,		1,		51053,	565.1690104,		0,					0.852168259,		1.484067068,		-5.415310976,		0,					0,				0,				28.11688423,		0				},
{	3,		1,		50890,	567.4254876,		0,					0.779067867,		1.398410066,		-4.970780383,		0,					0,				0,				30.02810167,		0				},
{	3,		1,		50777,	569.2472668,		0,					0.776319751,		1.393168314,		-4.923232758,		0,					0,				0,				30.40965112,		0				},
{	3,		1,		22201,	570.4586719,		0,					0.840041142,		2.145668329,		-6.419130989,		0,					0,				0,				23.57237805,		0				},
{	3,		1,		50697,	570.7580252,		0,					0.759151698,		1.375092468,		-4.776463651,		0,					0,				0,				30.39147775,		0				},
{	3,		1,		50632,	571.6910232,		0,					0.757882539,		1.366256357,		-4.724451867,		0,					0,				0,				30.45354899,		0				},
{	3,		1,		50564,	572.9153012,		0,					0.775180511,		1.413201939,		-4.853811652,		0,					0,				0,				29.85960829,		0				},
{	3,		1,		20643,	573.9204868,		0,					0.890419911,		2.142332596,		-6.5451341,			0,					0,				0,				23.56713956,		0				},
{	3,		1,		50482,	574.2907527,		0,					0.765581922,		1.412175371,		-4.840819988,		0,					0,				0,				29.19750642,		0				},
{	3,		1,		50362,	575.822164,			0,					0.754718188,		1.422170717,		-4.878659142,		0,					0,				0,				27.76049122,		0				},
{	3,		1,		19185,	576.7770928,		0,					0.958033135,		2.284598334,		-6.908239097,		0,					0,				0,				21.15300675,		0				},
{	3,		1,		50206,	577.6690341,		0,					0.779195932,		1.478909148,		-5.049721495,		0,					0,				0,				25.34130495,		0				},
{	3,		1,		50052,	578.9272132,		0,					0.759645741,		1.444364833,		-4.894060466,		0,					0,				0,				23.5528071,			0				},
{	3,		1,		17528,	579.0612833,		0,					0.884516266,		2.173507241,		-6.355734855,		0,					0,				0,				19.03180042,		0				},
{	3,		1,		49893,	580.3559782,		0,					0.793230366,		1.518059037,		-5.164996583,		0,					0,				0,				21.40124604,		0				},
{	3,		1,		15919,	580.8643622,		0,					0.90104456,			2.304862459,		-6.345597102,		0,					0,				0,				17.42149593,		0				},
{	3,		1,		49733,	581.3488428,		0,					0.781055938,		1.504732254,		-5.16274588,		0,					0,				0,				20.47096624,		0				},
{	3,		1,		49543,	582.7292078,		0,					0.751317323,		1.442056666,		-4.896550959,		0,					0,				0,				19.02937212,		0				},
{	3,		1,		13697,	582.798865,			0,					0.786753296,		2.148232069,		-5.302346642,		0,					0,				0,				16.36505308,		0				},
{	3,		1,		49321,	584.2438564,		0,					0.743875624,		1.440271997,		-4.976229583,		0,					0,				0,				18.26241369,		0				},
{	3,		1,		11127,	584.577535,			0,					0.702570403,		2.016995336,		-4.32210678,		0,					0,				0,				15.84827112,		0				},
{	3,		1,		49088,	585.3694778,		0,					0.733153851,		1.369648179,		-4.735854281,		0,					0,				0,				18.37784422,		0				},
{	3,		1,		48839,	586.9276645,		0,					0.724753728,		0.986128871,		-1.681801471,		0,					0,				0,				18.2243955,			0				},
{	3,		1,		48560,	588.6456362,		0,					0.728506244,		0.937587866,		-1.622649828,		0,					0,				0,				18.56222093,		0				},
{	3,		1,		48253,	590.5393079,		0,					0.744158985,		0.88514816,			-1.525211353,		0,					0,				0,				19.27394234,		0				},
{	3,		1,		48094,	591.3982859,		0,					0.760628926,		0.835279746,		-1.438857801,		0,					0,				0,				20.01336836,		0				},
{	3,		1,		47889,	592.81418,			0,					0.594304747,		0.65094055,			-1.113716978,		0,					0,				0,				20.46401659,		0				},
{	3,		1,		47730,	593.739605,			0,					0.603886231,		0.603691722,		-1.000897618,		0,					0,				0,				21.34032494,		0				},
{	3,		1,		47591,	594.8000063,		0,					0.612329433,		0.606278442,		-1.025343915,		0,					0,				0,				21.36901135,		0				},
{	3,		1,		47417,	596.1253968,		0,					0.624111123,		0.561621636,		-0.93260928,		0,					0,				0,				21.70120466,		0				},
{	3,		1,		47210,	597.4915382,		0,					0.611653059,		0.489185586,		-0.811610354,		0,					0,				0,				22.57745389,		0				},
{	3,		1,		47034,	598.7921007,		0,					0.622037276,		0.478965799,		-0.810232041,		0,					0,				0,				22.564328,			0				},
{	3,		1,		46815,	600.3957949,		0,					0.63670834,			0.421133211,		-0.719467142,		0,					0,				0,				22.66214846,		0				},
{	3,		1,		46599,	601.9699517,		0,					0.652610458,		0.345805132,		-0.615268858,		0,					0,				0,				22.63540382,		0				},
{	3,		1,		46437,	602.9370401,		0,					0.664102958,		0.295490915,		-0.55696577,		0,					0,				0,				22.9356541,			0				},
{	3,		1,		46187,	604.6604077,		0,					0.680739218,		0.197931137,		-0.420885807,		0,					0,				0,				22.71804056,		0				},
{	3,		1,		45962,	606.2737153,		0,					0.693497032,		0.118823297,		-0.313910699,		0,					0,				0,				22.45792472,		0				},
{	3,		1,		45752,	607.8110214,		0,					0.707229899,		0.044270126,		-0.199692953,		0,					0,				0,				22.35700311,		0				},
{	3,		1,		45496,	609.2273508,		0,					0.720774398,		-0.020241672,		-0.099332596,		0,					0,				0,				22.91106782,		0				},
{	3,		1,		45254,	610.8901883,		0,					0.729344654,		-0.067854852,		-0.034539597,		0,					0,				0,				22.84102075,		0				},
{	3,		1,		45061,	612.2236991,		0,					0.739095114,		-0.082160264,		-0.006386986,		0,					0,				0,				22.7860098,			0				},
{	4,		1,		53506,	695.9738452,		0,					0.746581945,		0.746581945,		0.746581945,		0,					0,				0,				30.93814177,		0				},
{	4,		1,		53474,	696.5177541,		0,					0.748715797,		0.748715797,		0.748715797,		0,					0,				0,				30.70235625,		0				},
{	4,		1,		53443,	697.0142294,		0,					0.748562313,		0.748562313,		0.748562313,		0,					0,				0,				30.75255492,		0				},
{	4,		1,		53406,	697.8388904,		0,					0.749183279,		0.749183279,		0.749183279,		0,					0,				0,				30.71341855,		0				},
{	4,		1,		53369,	698.4397829,		0,					0.746768858,		0.746768858,		0.746768858,		0,					0,				0,				30.64261763,		0				},
{	4,		1,		53324,	699.2120027,		0,					0.748185315,		0.748185315,		0.748185315,		0,					0,				0,				30.50172111,		0				},
{	4,		1,		53267,	700.3681425,		0,					0.745622963,		0.745622963,		0.745622963,		0,					0,				0,				30.14835899,		0				},
{	4,		1,		53204,	701.3626471,		0,					0.778601874,		0.778601874,		0.778601874,		0,					0,				0,				29.89283578,		0				},
{	4,		1,		53127,	702.699153,			0,					0.775326108,		0.775326108,		0.775326108,		0,					0,				0,				29.17794853,		0				},
{	4,		1,		53047,	704.0472836,		0,					0.773297916,		0.773297916,		0.773297916,		0,					0,				0,				28.64154628,		0				},
{	4,		1,		52971,	705.1396792,		0,					0.772186172,		0.772186172,		0.772186172,		0,					0,				0,				28.40290843,		0				},
{	4,		1,		52894,	706.430734,			0,					0.767808077,		0.767808077,		0.767808077,		0,					0,				0,				27.81992806,		0				},
{	4,		1,		52818,	707.5179887,		0,					0.766913588,		0.766913588,		0.766913588,		0,					0,				0,				27.83281096,		0				},
{	4,		1,		52735,	708.8201956,		0,					0.762761915,		0.762761915,		0.762761915,		0,					0,				0,				27.24806137,		0				},
{	4,		1,		52670,	709.6242043,		0,					0.761968164,		0.761968164,		0.761968164,		0,					0,				0,				27.34661845,		0				},
{	4,		1,		52576,	711.0000254,		0,					0.760171349,		0.760171349,		0.760171349,		0,					0,				0,				26.85256957,		0				},
{	4,		1,		52482,	712.3846959,		0,					0.757793513,		0.757793513,		0.757793513,		0,					0,				0,				26.50577862,		0				},
{	4,		1,		52386,	713.6188795,		0,					0.755700381,		0.755700381,		0.755700381,		0,					0,				0,				26.74199812,		0				},
{	4,		1,		52275,	715.113878,			0,					0.754258397,		0.754258397,		0.754258397,		0,					0,				0,				26.37634962,		0				},
{	4,		1,		52164,	716.5981701,		0,					0.753871822,		0.753871822,		0.753871822,		0,					0,				0,				26.20802433,		0				},
{	4,		1,		52064,	717.9418594,		0,					0.752551683,		0.752551683,		0.752551683,		0,					0,				0,				26.13935267,		0				},
{	4,		1,		51931,	719.5098051,		0,					0.755334872,		0.755334872,		0.755334872,		0,					0,				0,				26.61610174,		0				},
{	4,		1,		51811,	721.0083317,		0,					0.757691721,		0.757691721,		0.757691721,		0,					0,				0,				26.58153608,		0				},
{	4,		1,		51680,	722.7570446,		0,					0.758938102,		0.758938102,		0.758938102,		0,					0,				0,				26.84194763,		0				},
{	4,		1,		51545,	724.4711123,		0,					0.764289205,		0.764289205,		0.764289205,		0,					0,				0,				27.11282375,		0				},
{	4,		1,		51402,	726.4006888,		0,					0.767192498,		0.767192498,		0.767192498,		0,					0,				0,				27.66893726,		0				},
{	4,		1,		51220,	728.7928011,		0,					0.774962418,		0.774962418,		0.774962418,		0,					0,				0,				28.37251139,		0				},
{	4,		1,		51053,	730.9628162,		0,					0.781051702,		0.781051702,		0.781051702,		0,					0,				0,				28.92325637,		0				},
{	4,		1,		50890,	733.1221873,		0,					0.788246068,		0.788246068,		0.788246068,		0,					0,				0,				29.23268068,		0				},
{	4,		1,		50777,	734.7216809,		0,					0.792158161,		0.792158161,		0.792158161,		0,					0,				0,				29.25528885,		0				},
{	4,		1,		50697,	735.9350455,		0,					0.795712744,		0.795712744,		0.795712744,		0,					0,				0,				29.16523486,		0				},
{	4,		1,		50632,	736.702733,			0,					0.798140036,		0.798140036,		0.798140036,		0,					0,				0,				29.30022349,		0				},
{	4,		1,		50564,	737.7109515,		0,					0.803281419,		0.803281419,		0.803281419,		0,					0,				0,				29.01251715,		0				},
{	4,		1,		50482,	738.7581953,		0,					0.805015751,		0.805015751,		0.805015751,		0,					0,				0,				29.0922337,			0				},
{	5,		1,		50362,	740.2281587,		0,					0.810986945,		0.810986945,		0.810986945,		0,					0,				0,				28.68050028,		0				},
{	5,		1,		50206,	742.1788269,		0,					0.816883777,		0.816883777,		0.816883777,		0,					0,				0,				28.3201685,			0				},
{	5,		1,		50052,	744.036989,			0,					0.82283806,			0.82283806,			0.82283806,			0,					0,				0,				27.97360836,		0				},
{	5,		1,		49893,	745.9642397,		0,					0.829072819,		0.829072819,		0.829072819,		0,					0,				0,				27.64566091,		0				},
{	5,		1,		49733,	747.6041917,		0,					0.836200396,		0.836200396,		0.836200396,		0,					0,				0,				27.94905516,		0				},
{	5,		1,		49543,	749.9381558,		0,					0.843447562,		0.843447562,		0.843447562,		0,					0,				0,				27.33197503,		0				},
{	5,		1,		49321,	752.3395237,		0,					0.852575022,		0.852575022,		0.852575022,		0,					0,				0,				27.42599413,		0				},
{	5,		1,		49088,	754.8344514,		0,					0.858244121,		0.858244121,		0.858244121,		0,					0,				0,				27.80951713,		0				},
{	5,		1,		48839,	757.5806071,		0,					0.867229188,		0.867229188,		0.867229188,		0,					0,				0,				28.42481736,		0				},
{	5,		1,		48560,	760.7185241,		0,					0.872686178,		0.872686178,		0.872686178,		0,					0,				0,				28.33063225,		0				},
{	5,		1,		48253,	764.1610656,		0,					0.879067825,		0.879067825,		0.879067825,		0,					0,				0,				28.25631404,		0				},
{	5,		1,		48094,	765.9698975,		0,					0.992046091,		0.992046091,		0.992046091,		0,					0,				0,				27.76455002,		0				},
{	5,		1,		47889,	768.1400458,		0,					0.965303905,		0.965303905,		0.965303905,		0,					0,				0,				28.15816651,		0				},
{	5,		1,		47730,	769.5973165,		0,					0.947752052,		0.947752052,		0.947752052,		0,					0,				0,				28.3401023,			0				},
{	5,		1,		47591,	771.1035987,		0,					0.930654626,		0.930654626,		0.930654626,		0,					0,				0,				28.25684381,		0				},
{	5,		1,		47417,	772.9271001,		0,					0.885520833,		0.885520833,		0.885520833,		0,					0,				0,				28.09913719,		0				},
{	5,		1,		47210,	775.054537,			0,					0.900191571,		0.900191571,		0.900191571,		0,					0,				0,				28.04222696,		0				},
{	5,		1,		47034,	776.8154742,		0,					0.898509472,		0.898509472,		0.898509472,		0,					0,				0,				27.84959284,		0				},
{	5,		1,		46815,	778.9766281,		0,					0.888333273,		0.888333273,		0.888333273,		0,					0,				0,				27.72360981,		0				},
{	6,		1,		47210,	775.054537,			0,					0.887421526,		0.887421526,		0.887421526,		0,					0,				0,				28.04222696,		0				},
{	6,		1,		47034,	776.8154742,		0,					0.886987497,		0.886987497,		0.886987497,		0,					0,				0,				27.84959284,		0				},
{	6,		1,		46815,	778.9766281,		0,					0.888333268,		0.888333268,		0.888333268,		0,					0,				0,				27.72360981,		0				},
{	6,		1,		46599,	781.035431,			0,					0.886869539,		0.886869539,		0.886869539,		0,					0,				0,				27.72688776,		0				},
{	6,		1,		46437,	782.625361,			0,					0.887187115,		0.887187115,		0.887187115,		0,					0,				0,				27.37679808,		0				},
{	6,		1,		46187,	784.9066785,		0,					0.883356772,		0.883356772,		0.883356772,		0,					0,				0,				27.28661309,		0				},
{	6,		1,		45962,	786.9937188,		0,					0.884575538,		0.884575538,		0.884575538,		0,					0,				0,				27.04241125,		0				},
{	6,		1,		45752,	788.8811915,		0,					0.882422662,		0.882422662,		0.882422662,		0,					0,				0,				26.68556916,		0				},
{	6,		1,		45496,	791.0757294,		0,					0.884727079,		0.884727079,		0.884727079,		0,					0,				0,				26.2871005,			0				},
{	6,		1,		45254,	793.0999604,		0,					0.930060342,		0.930060342,		0.930060342,		0,					0,				0,				25.94663827,		0				},
{	6,		1,		45061,	794.65877,			0,					0.927215664,		0.927215664,		0.927215664,		0,					0,				0,				25.57100081,		0				},
{	6,		1,		44748,	797.0926164,		0,					0.928295015,		0.928295015,		0.928295015,		0,					0,				0,				25.38536911,		0				},
{	6,		1,		44504,	798.9352668,		0,					0.927651805,		0.927651805,		0.927651805,		0,					0,				0,				25.22208392,		0				},
{	6,		1,		44248,	800.8814747,		0,					0.930350147,		0.930350147,		0.930350147,		0,					0,				0,				25.21518763,		0				},
{	6,		1,		43978,	802.8886048,		0,					0.937935397,		0.937935397,		0.937935397,		0,					0,				0,				25.27232543,		0				},
{	6,		1,		43666,	805.2031018,		0,					0.944293205,		0.944293205,		0.944293205,		0,					0,				0,				25.68541051,		0				},
{	6,		1,		43342,	807.605824,			0,					0.906926506,		0.906926506,		0.906926506,		0,					0,				0,				26.28255244,		0				},
{	6,		1,		43048,	810.0078184,		0,					0.916808485,		0.916808485,		0.916808485,		0,					0,				0,				26.07541549,		0				},
{	6,		1,		42762,	812.1787201,		0,					0.924286815,		0.924286815,		0.924286815,		0,					0,				0,				26.3647768,			0				},
{	6,		1,		42421,	814.6816717,		0,					0.93285395,			0.93285395,			0.93285395,			0,					0,				0,				26.61472224,		0				},
{	6,		1,		42156,	816.6738759,		0,					0.941765373,		0.941765373,		0.941765373,		0,					0,				0,				26.60259792,		0				},
{	6,		1,		41863,	818.8148698,		0,					0.949397009,		0.949397009,		0.949397009,		0,					0,				0,				26.49742322,		0				},
{	7,		1,		43048,	810.0078184,		0,					0.916808485,		0.916808485,		0.916808485,		0,					0,				0,				26.07541549,		0				},
{	7,		1,		42762,	812.1787201,		0,					0.924286815,		0.924286815,		0.924286815,		0,					0,				0,				26.3647768,			0				},
{	7,		1,		42421,	814.6816717,		0,					0.93285395,			0.93285395,			0.93285395,			0,					0,				0,				26.61472224,		0				},
{	7,		1,		42156,	816.6738759,		0,					0.941765373,		0.941765373,		0.941765373,		0,					0,				0,				26.60259792,		0				},
{	7,		1,		41863,	818.8148698,		0,					0.949397009,		0.949397009,		0.949397009,		0,					0,				0,				26.49742322,		0				},
{	7,		1,		41531,	821.2137623,		0,					0.963146822,		0.963146822,		0.963146822,		0,					0,				0,				26.3829814,			0				},
{	7,		1,		41210,	823.4274442,		0,					0.975089548,		0.975089548,		0.975089548,		0,					0,				0,				26.12143803,		0				},
{	7,		1,		40906,	825.4751971,		0,					1.036907375,		1.036907375,		1.036907375,		0,					0,				0,				25.86337652,		0				},
{	7,		1,		40493,	828.2994597,		0,					1.051178997,		1.051178997,		1.051178997,		0,					0,				0,				25.17826076,		0				},
{	7,		1,		40138,	830.543004,			0,					1.064032631,		1.064032631,		1.064032631,		0,					0,				0,				25.11210789,		0				},
{	7,		1,		39769,	832.800712,			0,					1.082382236,		1.082382236,		1.082382236,		0,					0,				0,				25.10562521,		0				},
{	7,		1,		39382,	835.1473759,		0,					1.103546568,		1.103546568,		1.103546568,		0,					0,				0,				25.35584793,		0				},
{	7,		1,		38981,	837.7754231,		0,					1.121424108,		1.121424108,		1.121424108,		0,					0,				0,				25.08816596,		0				},
{	7,		1,		38481,	840.6502696,		0,					1.145514456,		1.145514456,		1.145514456,		0,					0,				0,				25.45428338,		0				},
{	7,		1,		38137,	842.6895304,		0,					1.171281506,		1.171281506,		1.171281506,		0,					0,				0,				25.4590466,			0				},
{	7,		1,		37700,	845.259572,			0,					1.198015622,		1.198015622,		1.198015622,		0,					0,				0,				25.7653178,			0				},
{	7,		1,		37248,	848.0322309,		0,					1.225122331,		1.225122331,		1.225122331,		0,					0,				0,				25.3959769,			0				},
{	8,		1,		36696,	851.0365439,		0,					1.263342528,		1.263342528,		1.263342528,		0,					0,				0,				25.64291477,		0				},
{	8,		1,		36316,	853.1906881,		0,					1.28553785,			1.28553785,			1.28553785,			0,					0,				0,				25.61949334,		0				},
{	8,		1,		35736,	856.3989848,		0,					1.324725753,		1.324725753,		1.324725753,		0,					0,				0,				25.07409797,		0				},
{	8,		1,		35239,	858.9645247,		0,					1.359751776,		1.359751776,		1.359751776,		0,					0,				0,				25.12505008,		0				},
{	8,		1,		34667,	861.9830172,		0,					1.408743992,		1.408743992,		1.408743992,		0,					0,				0,				24.79235414,		0				},
{	8,		1,		34141,	864.5725472,		0,					1.448527255,		1.448527255,		1.448527255,		0,					0,				0,				24.77633448,		0				},
{	8,		1,		33519,	867.7349273,		0,					1.503987295,		1.503987295,		1.503987295,		0,					0,				0,				24.66950096,		0				},
{	8,		1,		32902,	870.5373699,		0,					1.559889474,		1.559889474,		1.559889474,		0,					0,				0,				24.76030718,		0				},
{	8,		1,		32410,	872.7756732,		0,					1.601662123,		1.601662123,		1.601662123,		0,					0,				0,				24.8645905,			0				},
{	8,		1,		31672,	876.198313,			0,					1.685037851,		1.685037851,		1.685037851,		0,					0,				0,				24.57664031,		0				},
{	8,		1,		30938,	879.3187581,		0,					1.761885831,		1.761885831,		1.761885831,		0,					0,				0,				25.01312093,		0				},
{	8,		1,		30333,	882.0454878,		0,					1.81445258,			1.81445258,			1.81445258,			0,					0,				0,				24.52162297,		0				},
{	8,		1,		29619,	884.9127847,		0,					1.889092586,		1.889092586,		1.889092586,		0,					0,				0,				24.65569982,		0				},
{	8,		1,		28789,	888.289773,			0,					1.979795182,		1.979795182,		1.979795182,		0,					0,				0,				24.33113003,		0				},
{	8,		1,		28011,	891.2073289,		0,					2.068879444,		2.068879444,		2.068879444,		0,					0,				0,				24.65087495,		0				},
{	8,		1,		27229,	894.2519388,		0,					2.152347077,		2.152347077,		2.152347077,		0,					0,				0,				23.97315305,		0				},
{	8,		1,		26226,	897.9256904,		0,					2.254726566,		2.254726566,		2.254726566,		0,					0,				0,				23.91102527,		0				},
{	8,		1,		25324,	900.9252753,		0,					2.326559343,		2.326559343,		2.326559343,		0,					0,				0,				24.2601732,			0				},
{	8,		1,		24267,	904.4808982,		0,					2.444019746,		2.444019746,		2.444019746,		0,					0,				0,				23.85732504,		0				},
{	8,		1,		23113,	908.1626284,		0,					2.565109333,		2.565109333,		2.565109333,		0,					0,				0,				23.65250144,		0				},
{	8,		1,		22201,	910.7679657,		0,					2.659032063,		2.659032063,		2.659032063,		0,					0,				0,				23.61148821,		0				},
{	8,		1,		20643,	915.0569782,		0,					2.790802649,		2.790802649,		2.790802649,		0,					0,				0,				23.63308132,		0				},
{	8,		1,		19185,	918.7635647,		0,					2.895864847,		2.895864847,		2.895864847,		0,					0,				0,				23.03728832,		0				},
{	8,		1,		17528,	922.5570782,		0,					3.041812021,		3.041812021,		3.041812021,		0,					0,				0,				22.77527789,		0				},
{	8,		1,		15919,	925.9430457,		0,					3.166004391,		3.166004391,		3.166004391,		0,					0,				0,				22.36363281,		0				},
{	8,		1,		13697,	929.8255444,		0,					3.321850017,		3.321850017,		3.321850017,		0,					0,				0,				22.30192325,		0				},
{	8,		1,		11127,	933.2791575,		0,					3.529661753,		3.529661753,		3.529661753,		0,					0,				0,				22.93313867,		0				},

};

/*------------------------------------------------------------------------------
 * Function declarations
 *----------------------------------------------------------------------------*/


/***************************************************************************//**
 *
 *	\brief		Main application entry point
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	Main application entry point
 *
 * 	\note
 *	
 ******************************************************************************/
long findNearestWavelength(
	double					userWavelength
) {
	long					ii;
	long					suitableIdx;
	double					lowLimit;
	double					highLimit;

	lowLimit = 
	suitableIdx = -1;

	for (ii=0;ii<CALIBROW_COUNT;ii++) {

		double 				wavelength1;
		double 				wavelength2;
		double 				diff;

		wavelength1 = calibRows[ii][3];
		wavelength2 = calibRows[ii][4];

		/*
		printf("Wavelenghts: %f, %f\r\n", wavelength1, wavelength2);
		*/

		diff = userWavelength - wavelength1;

		if (diff > -2.5 && diff < 2.5) {

			printf("Found suitable wavelength at [%ld] with center %f and diff: %f\r\n", ii, wavelength1, diff);
			suitableIdx = ii;
			break;

		} else {

			diff = userWavelength - wavelength2;

			if (diff > -2.5 && diff < 2.5) {

				printf("Found suitable wavelength at [%ld] with center %f and diff: %f\r\n", ii, wavelength2, diff);
				suitableIdx = ii;
				break;
			}
		}
	}

	return suitableIdx;
}

/***************************************************************************//**
 *
 *	\brief		Main application entry point
 *
 * 	\param		
 * 
 *	\return		
 *
 *	\details	Main application entry point
 *
 * 	\note
 *	
 ******************************************************************************/
void main(
	int						argc,
	char					argv[]
) {
	long					ii;
	long					suitableIdx;
	double					userWavelength;

	ii = 0;

	do {
	
		userWavelength = (double)ii * (double)0.1 + (double)542;

		suitableIdx = findNearestWavelength(userWavelength);

		if (suitableIdx == -1) {
			printf("No suitable wavelength setting was found for: %f!\r\n", userWavelength);
			break;
		}

		ii++;

	} while (userWavelength < (double)934.0);

	printf("Checked all wavelengths between 542.1 to 934.0 nm\r\n");
}
