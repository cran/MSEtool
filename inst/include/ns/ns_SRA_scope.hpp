
namespace ns_SRA_scope {

using namespace ns_SCA;

template <class Type>
Type log2(Type x) {
  return log(x)/log(Type(2));
}

template<class Type>
matrix<Type> generate_ALK(vector<Type> length_bin, matrix<Type> len_age, Type CV_LAA, int max_age, int nlbin, Type bin_width, int y) {
  matrix<Type> ALK(max_age, length_bin.size());
  for(int a=0;a<max_age;a++) {
    for(int j=0;j<nlbin;j++) {
      if(j==nlbin-1) {
        ALK(a,j) = 1 - pnorm(length_bin(j) - 0.5 * bin_width, len_age(y,a), CV_LAA * len_age(y,a));
      } else {
        ALK(a,j) = pnorm(length_bin(j) + 0.5 * bin_width, len_age(y,a), CV_LAA * len_age(y,a));
        if(j>0) ALK(a,j) -= pnorm(length_bin(j) - 0.5 * bin_width, len_age(y,a), CV_LAA * len_age(y,a));
      }
    }
  }
  return ALK;
}

template<class Type>
vector<Type> calc_NPR0(matrix<Type> M, int max_age, int y) {
  vector<Type> NPR(max_age);
  NPR(0) = 1;
  for(int a=1;a<max_age;a++) NPR(a) = NPR(a-1) * exp(-M(y,a-1));
  NPR(max_age-1) /= 1 - exp(-M(y,max_age-1));
  return NPR;
}


template<class Type>
vector<Type> calc_NPR(vector<Type> F, array<Type> vul, int nfleet, matrix<Type> M, int max_age, int y) {
  vector<Type> NPR(max_age);
  vector<Type> Z = M.row(y);
  NPR(0) = 1;
  for(int a=0;a<max_age;a++) {
    for(int ff=0;ff<nfleet;ff++) Z(a) += vul(y,a,ff) * F(ff);
    if(a > 0) NPR(a) = NPR(a-1) * exp(-Z(a-1));
  }
  NPR(max_age-1) /= 1 - exp(-Z(max_age-1));
  return NPR;
}

template<class Type>
Type sum_EPR(vector<Type> NPR, matrix<Type> wt, matrix<Type> mat, int max_age, int y) {
  Type EPR = 0.;
  for(int a=0;a<max_age;a++) EPR += NPR(a) * wt(y,a) * mat(y,a);
  return EPR;
}

template<class Type>
Type sum_BPR(vector<Type> NPR, matrix<Type> wt, int max_age, int y) {
  Type BPR = 0;
  for(int a=0;a<max_age;a++) BPR += NPR(a) * wt(y,a);
  return BPR;
}


template<class Type>
array<Type> calc_vul(matrix<Type> vul_par, vector<int> vul_type, matrix<Type> Len_age, vector<Type> &LFS, vector<Type> &L5,
                     vector<Type> &Vmaxlen, Type Linf) {
  array<Type> vul(Len_age.rows(), Len_age.cols(), vul_type.size());
  vul.setZero();

  for(int ff=0;ff<vul_type.size();ff++) {

    if(vul_type(ff) <= 0) { // Logistic or dome
      LFS(ff) = invlogit(vul_par(0,ff)) * 0.95 * Linf;
      L5(ff) = LFS(ff) - exp(vul_par(1,ff));
      Type sls = (LFS(ff) - L5(ff))/pow(-log2(0.05), 0.5);
      if(vul_type(ff) < 0) { // Logistic
        Vmaxlen(ff) = 1;
      } else { // Dome
        Vmaxlen(ff) = invlogit(vul_par(2,ff));
      }

      for(int y=0;y<Len_age.rows();y++) {
        for(int a=0;a<Len_age.cols();a++) {
          Type lo = pow(2, -((Len_age(y,a) - LFS(ff))/sls * (Len_age(y,a) - LFS(ff))/sls));
          Type hi;

          if(vul_type(ff) < 0) { // Logistic
            hi = 1;
          } else { // Dome
            Type srs = (Linf - LFS(ff))/pow(-log2(Vmaxlen(ff)), 0.5);
            hi = pow(2, -((Len_age(y,a) - LFS(ff))/srs * (Len_age(y,a) - LFS(ff))/srs));
          }
          vul(y,a,ff) = CppAD::CondExpLt(Len_age(y,a), LFS(ff), lo, hi);
        }
      }

    } else { // Age-specific index
      for(int y=0;y<Len_age.rows();y++) vul(y,vul_type(ff)-1,ff) = 1;
    }
  }
  return vul;
}



template<class Type>
array<Type> calc_vul_sur(matrix<Type> vul_par, vector<int> vul_type, matrix<Type> Len_age, vector<Type> &LFS, vector<Type> &L5,
                         vector<Type> &Vmaxlen, Type Linf, matrix<Type> mat, vector<int> I_type, array<Type> fleet_var) {
  array<Type> vul(Len_age.rows(), Len_age.cols(), vul_type.size());
  vul.setZero();

  for(int ff=0;ff<vul_type.size();ff++) {

    if(I_type(ff) == -2) { // SSB

      for(int y=0;y<Len_age.rows();y++) {
        for(int a=0;a<Len_age.cols();a++) vul(y,a,ff) = mat(y,a);
      }

    } else if(I_type(ff) == -1) { // B

      for(int y=0;y<Len_age.rows();y++) {
        for(int a=0;a<Len_age.cols();a++) vul(y,a,ff) = 1;
      }

    } else if(I_type(ff) == 0) { // est

      if(vul_type(ff) <= 0) { // Logistic or dome
        LFS(ff) = invlogit(vul_par(0,ff)) * 0.95 * Linf;
        L5(ff) = LFS(ff) - exp(vul_par(1,ff));
        Type sls = (LFS(ff) - L5(ff))/pow(-log2(0.05), 0.5);
        if(vul_type(ff) < 0) { // Logistic
          Vmaxlen(ff) = 1;
        } else { // Dome
          Vmaxlen(ff) = invlogit(vul_par(2,ff));
        }

        for(int y=0;y<Len_age.rows();y++) {
          for(int a=0;a<Len_age.cols();a++) {
            Type lo = pow(2, -((Len_age(y,a) - LFS(ff))/sls * (Len_age(y,a) - LFS(ff))/sls));
            Type hi;

            if(vul_type(ff) < 0) { // Logistic
              hi = 1;
            } else { // Dome
              Type srs = (Linf - LFS(ff))/pow(-log2(Vmaxlen(ff)), 0.5);
              hi = pow(2, -((Len_age(y,a) - LFS(ff))/srs * (Len_age(y,a) - LFS(ff))/srs));
            }
            vul(y,a,ff) = CppAD::CondExpLt(Len_age(y,a), LFS(ff), lo, hi);
          }
        }
      } else { // Age-specific index
        for(int y=0;y<Len_age.rows();y++) vul(y,vul_type(ff)-1,ff) = 1;
      }

    } else { // Mirrored index to fleet
      vul.col(ff) = fleet_var.col(I_type(ff) - 1);
    }
  }
  return vul;
}


// Calculates analytical solution of catchability when conditioned on catch and
// index is lognormally distributed.
template<class Type>
Type calc_q(matrix<Type> I_y, matrix<Type> B_y, int sur, int ff, matrix<Type> &Ipred, vector<int> abs_I, Type rescale) {
  Type q;
  if(abs_I(sur)) { // q = 1 after rescaling
    q = 1/rescale;
  } else {
    Type num = 0.;
    Type n_y = 0.;

    for(int y=0;y<I_y.rows();y++) {
      if(!R_IsNA(asDouble(I_y(y,sur))) && I_y(y,sur)>0) {
        num += log(I_y(y,sur)/B_y(y,ff));
        n_y += 1.;
      }
    }
    q = exp(num/n_y);
  }
  for(int y=0;y<I_y.rows();y++) Ipred(y,sur) = q * B_y(y,ff);
  return q;
}


// Multinomial likelihood
template<class Type>
Type comp_multinom(array<Type> obs, array<Type> pred, matrix<Type> N, matrix<Type> N_samp, int y, int n_bin, int ff) {
  vector<Type> p_pred(n_bin);
  vector<Type> N_obs(n_bin);
  for(int bb=0;bb<n_bin;bb++) {
    p_pred(bb) = pred(y,bb,ff)/N(y,ff);
    N_obs(bb) = obs(y,bb,ff);
  }
  Type nll = dmultinom(N_obs, p_pred, true);
  return nll;
}

template<class Type>
Type comp_lognorm(array<Type> obs, array<Type> pred, matrix<Type> N, matrix<Type> N_samp, int y, int n_bin, int ff) {
  Type nll = 0;
  for(int bb=0;bb<n_bin;bb++) {
    Type p_pred = pred(y,bb,ff)/N(y,ff);
    Type p_obs = obs(y,bb,ff)/N_samp(y,ff);
    nll -= dnorm(log(p_obs), log(p_pred), pow(0.02/p_obs, 0.5), true);
  }
  return nll;
}



}
