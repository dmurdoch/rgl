#ifndef RGL_PRETTY_H
#define RGL_PRETTY_H

#ifdef __cplusplus
extern "C" {
#endif

double R_pretty0(double *lo, double *up, int *ndiv, int min_n,
	       double shrink_sml, double high_u_fact[],
	       int eps_correction, int return_bounds);
	       
#ifdef __cplusplus
}
#endif

#endif /* RGL_API_H */
	       
