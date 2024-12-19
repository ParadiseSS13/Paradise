#define NOVICE_JOB_MINUTES 120
#define NOVICE_CADET_JOB_MINUTES 300

// Если ОФФы добавят новую должность в отдел, то потребуется смещение (╯°□°）╯︵ ┻━┻
// Но так как они больше не планируют и выступают против добавления новых профессий, скорее всего ничего и не изменится.

// JOBCAT_"отдел"_LAST - нужен для корректного вывода из БД, иначе чуда не будет.
// Максимальный сдвиг (1<<22), Последний сдвиг (1<<23)
// Он должен быть всегда как минимум на 1 больше последнего, по дефолту у ОФФов (1<<16)


// ====================================
//			JOBCAT_ENGSEC
// Начинаются с JOB_NANO		(1<<14)
#define JOB_TRAINEE				(1<<15)
#define JOB_CADET				(1<<16)
//#define JOB_PILOT				(1<<17)

#define JOB_REPRESENTATIVE_TSF	(1<<17)
#define JOB_REPRESENTATIVE_USSP	(1<<18)
#define JOB_DEALER				(1<<19)
#define JOB_VIP_GUEST			(1<<20)
#define JOB_BANKER				(1<<21)
#define JOB_SECURITY_CLOWN		(1<<22)

#define JOBCAT_LAST_ENGSEC		(1<<23)


// ====================================
//			JOBCAT_MEDSCI
// Начинаются с JOB_CORONER		(1<<10)
#define JOB_INTERN				(1<<11)
#define JOB_STUDENT				(1<<12)
#define JOB_MECHANIC			(1<<13)

#define JOB_ADMINISTRATOR		(1<<14)
#define JOB_TOURIST_TSF			(1<<15)
#define JOB_TOURIST_USSP		(1<<16)
#define JOB_MANAGER_JANITOR		(1<<17)
#define JOB_ACTOR				(1<<18)
//#define JOB_APPRENTICE		(1<<18)
#define JOB_GUARD				(1<<19)
#define JOB_MIGRANT				(1<<20)
#define JOB_UNCERTAIN			(1<<21)
#define JOB_ADJUTANT			(1<<22)
//#define JOB_MAID				(1<<23)
//#define JOB_BUTLER			(1<<24)

#define JOBCAT_LAST_MEDSCI		(1<<23)


// ====================================
//			JOBCAT_SUPPORT
// Начинаются с JOB_EXPLORER	(1<<14)
#define JOB_PRISON				(1<<15)
#define JOB_BARBER				(1<<16)
#define JOB_BATH				(1<<17)
#define JOB_CASINO				(1<<18)
#define JOB_WAITER				(1<<19)
#define JOB_ACOLYTE				(1<<20)
//#define JOB_DELIVERER			(1<<21)
#define JOB_BOXER				(1<<21)
#define JOB_MUSICIAN			(1<<22)
//#define JOB_PAINTER			(1<<24)

#define JOBCAT_LAST_SUPPORT		(1<<23)







// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// В ЭТОМ ФАЙЛЕ МЫ [B]ВРЕМЕННО[/B] ЗАСОВЫВАЕМ
// НАШИ ДЕФАЙНЫ ПОД КАТЕГОРИИ РАЗНЫХ ОТДЕЛОВ!
// ПРАВИЛЬНАЯ РАСФАСОВКА НИЖЕ
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

/*
// ====================================
//			JOBCAT_ENGSEC
// Начинаются с JOB_NANO		(1<<14)
#define JOB_TRAINEE				(1<<15)
#define JOB_CADET				(1<<16)
#define JOBCAT_LAST_ENGSEC		(1<<17)


// ====================================
//			JOBCAT_MEDSCI
// Начинаются с JOB_CORONER		(1<<10)
#define JOB_INTERN				(1<<11)
#define JOB_STUDENT				(1<<12)
#define JOBCAT_LAST_MEDSCI		(1<<16)


// ====================================
//			JOBCAT_SUPPORT
// Начинаются с JOB_EXPLORER	(1<<14)
// TIER 1
#define JOB_PRISON				(1<<15)

// TIER 2
#define JOB_BARBER				(1<<16)
#define JOB_BATH				(1<<17)
#define JOB_CASINO				(1<<18)
#define JOB_WAITER				(1<<19)
#define JOB_ACOLYTE				(1<<20)
#define JOB_DELIVERER			(1<<21)
#define JOB_BOXER				(1<<22)
#define JOB_PAINTER				(1<<23)
#define JOB_MUSICIAN			(1<<24)
#define JOB_DONOR				(1<<24)	// Свободная роль, можно переименовать
#define JOB_ACTOR				(1<<26)

// TIER 3
#define JOB_ADMINISTRATOR		(1<<27)
#define JOB_TOURIST_TSF			(1<<28)
#define JOB_TOURIST_USSP		(1<<29)
#define JOB_MANAGER_JANITOR		(1<<30)
#define JOB_APPRENTICE			(1<<31)
#define JOB_GUARD				(1<<32)
#define JOB_MIGRANT				(1<<33)
#define JOB_UNCERTAIN			(1<<34)

// TIER 4
#define JOB_ADJUTANT			(1<<35)
#define JOB_BUTLER				(1<<36)
#define JOB_MAID				(1<<37)
#define JOB_REPRESENTATIVE_TSF	(1<<38)
#define JOB_REPRESENTATIVE_USSP	(1<<39)
#define JOB_DEALER				(1<<40)

// TIER 5
#define JOB_VIP_GUEST			(1<<41)
#define JOB_BANKER				(1<<42)
#define JOB_SECURITY_CLOWN		(1<<43)

#define JOBCAT_LAST_SUPPORT		(1<<44)

*/
