%if 0%{?fedora} >= 15 || 0%{?rhel} >= 7
%global with_nfsidmap 1
%else
%global with_nfsidmap 0
%endif

%if %{?_with_gpfs:1}%{!?_with_gpfs:0}
%global with_fsal_gpfs 1
%else
%global with_fsal_gpfs 0
%endif

%if %{?_with_zfs:1}%{!?_with_zfs:0}
%global with_fsal_zfs 1
%else
%global with_fsal_zfs 0
%endif

%if %{?_with_xfs:1}%{!?_with_xfs:0}
%global with_fsal_xfs 1
%else
%global with_fsal_xfs 0
%endif

%if %{?_with_ceph:1}%{!?_with_ceph:0}
%global with_fsal_ceph 1
%else
%global with_fsal_ceph 0
%endif

%if %{?_with_lustre:1}%{!?_with_lustre:0}
%global with_fsal_lustre 1
%else
%global with_fsal_lustre 0
%endif

%if %{?_with_shook:1}%{!?_with_shook:0}
%global with_fsal_shook 1
%else
%global with_fsal_shook 0
%endif

%if %{?_with_gluster:1}%{!?_with_gluster:0}
%global with_fsal_gluster 1
%else
%global with_fsal_gluster 0
%endif

%if %{?_with_hpss:1}%{!?_with_hpss:0}
%global with_fsal_hpss 1
%else
%global with_fsal_hpss 0
%endif

%if %{?_with_pt:1}%{!?_with_pt:0}
%global with_fsal_pt 1
%else
%global with_fsal_pt 0
%endif

#%define sourcename nfs-ganesha-2.0-RC5-0.1.1-Source
%define sourcename @CPACK_SOURCE_PACKAGE_FILE_NAME@

Name:		nfs-ganesha
Version:	2.0
Release:	1%{?dist}
Summary:	NFS-Ganesha is a NFS Server running in user space
Group:		Applications/System
License:	LGPLv3	
Url:		http://nfs-ganesha.sourceforge.net
Source:		%{sourcename}.tar.gz
BuildRequires:	initscripts
BuildRequires:	cmake 
BuildRequires:	dbus-devel  libcap-devel krb5-devel libgssglue-devel bison flex
Requires:	dbus-libs libcap krb5-libs libgssglue 
%if %{with_nfsidmap}
BuildRequires:	libnfsidmap-devel
Requires:	libnfsidmap
%else
BuildRequires:	nfs-utils-lib-devel
Requires:	nfs-utils-lib
%endif

# Use CMake variables

%description
nfs-ganesha : NFS-GANESHA is a NFS Server running in user space.
It comes with various back-end modules (called FSALs) provided as
 shared objects to support different file systems and name-spaces.

%package mount-9P
Summary: a 9p mount helper
Group: Applications/System

%description mount-9P
This package contains the mount.9P script
This is a 9p mount help
 
%package vfs
Summary: The NFS-GANESHA's VFS FSAL
Group: Applications/System
BuildRequires: libattr-devel

%description vfs
This package contains a FSAL shared object to 
be used with NFS-Ganesha to support VFS based filesystems

%package nullfs
Summary: The NFS-GANESHA's NULLFS Stackable FSAL
Group: Applications/System

%description nullfs
This package contains a Stackble FSAL shared object to 
be used with NFS-Ganesha. This is mostly a template for future (more sophisticated) stackable FSALs

%package proxy
Summary: The NFS-GANESHA'snfs-ganesha-2.0-0.1.1-Source. PROXY FSAL
Group: Applications/System
BuildRequires: libattr-devel

%description proxy
This package contains a FSAL shared object to 
be used with NFS-Ganesha to support PROXY based filesystems

# Option packages start here. use "rpmbuild --with lustre" (or equivalent)
# for activating this part of the spec file

# GPFS
%if %{with_fsal_gpfs}
%package gpfs
Summary: The NFS-GANESHA's GPFS FSAL
Group: Applications/System

%description gpfs
This package contains a FSAL shared object to 
be used with NFS-Ganesha to support GPFS backend
%endif

# ZFS
%if %{with_fsal_zfs}
%package zfs
Summary: The NFS-GANESHA's ZFS FSAL
Group: Applications/System
Requires: libzfswrap
BuildRequires: libzfswrap-devel

%description zfs
This package contains a FSAL shared object to 
be used with NFS-Ganesha to support ZFS 
%endif

# CEPH
%if %{with_fsal_ceph}
%package ceph
Summary: The NFS-GANESHA's ZFS FSAL
Group: Applications/System

%description ceph
This package contains a FSAL shared object to 
be used with NFS-Ganesha to support CEPH 
%endif

# CEPH
%if %{with_fsal_ceph}
%package ceph
Summary: The NFS-GANESHA's ZFS FSAL
Group: Applications/System

%description ceph
This package contains a FSAL shared object to 
be used with NFS-Ganesha to support CEPH 
%endif

# LUSTRE
%if %{with_fsal_lustre}
%package lustre
Summary: The NFS-GANESHA's LUSTRE FSAL
Group: Applications/System
Requires: libattr lustre
BuildRequires: libattr-devel lustre

%description lustre
This package contains a FSAL shared object to 
be used with NFS-Ganesha to support LUSTRE
%endif

# SHOOK
%if %{with_fsal_shook}
%package shook
Summary: The NFS-GANESHA's LUSTRE/SHOOK FSAL
Group: Applications/System
Requires: libattr lustre shook
BuildRequires: libattr-devel lustre shook-devel

%description shook
This package contains a FSAL shared object to 
be used with NFS-Ganesha to support LUSTRE via SHOOK
%endif

# XFS
%if %{with_fsal_xfs}
%package xfs
Summary: The NFS-GANESHA's XFS FSAL
Group: Applications/System
Requires: libattr xfsprogs 
BuildRequires: libattr-devel xfsprogs-devel

%description xfs
This package contains a shared object to be used with FSAL_VFS
to support XFS correctly
%endif

# HPSS
%if %{with_fsal_hpss}
%package hpss
Summary: The NFS-GANESHA's HPSS FSAL
Group: Applications/System
Requires: 
BuildRequires:

%description hpss
This package contains a FSAL shared object to 
be used with NFS-Ganesha to support HPSS 
%endif

# PT
%if %{with_fsal_pt}
%package hpss
Summary: The NFS-GANESHA's PT FSAL
Group: Applications/System
Requires: 
BuildRequires:

%description pt
This package contains a FSAL shared object to 
be used with NFS-Ganesha to support PT 
%endif

# GLUSTER
%if %{with_fsal_gluster}
%package hpss
Summary: The NFS-GANESHA's GLSUTER FSAL
Group: Applications/System
Requires: 
BuildRequires:

%description gluster
This package contains a FSAL shared object to 
be used with NFS-Ganesha to support Gluster 
%endif

%prep
%setup -q -n %{sourcename} 

%build
cmake .	-DCMAKE_BUILD_TYPE=Debug			\
	-DCMAKE_INSTALL_PREFIX=$RPM_BUILD_ROOT/usr	\
	-DCMAKE_BUILD_TYPE=Debug			\
	-DBUILD_CONFIG=rpmbuild				\
%if %{with_fsal_zfs} 
	-DUSE_FSAL_XFS=ON				\
%else
	-DUSE_FSAL_XFS=OFF				\
%endif
%if %{with_fsal_zfs} 
	-DUSE_FSAL_ZFS=ON				\
%else
	-DUSE_FSAL_ZFS=OFF				\
%endif
%if %{with_fsal_ceph} 
	-DUSE_FSAL_CEPH=ON				\
%else
	-DUSE_FSAL_CEPH=OFF				\
%endif
%if %{with_fsal_lustre} 
	-DUSE_FSAL_LUSTRE=ON				\
%else
	-DUSE_FSAL_LUSTRE=OFF				\
%endif
%if %{with_fsal_shook} 
	-DUSE_FSAL_SHOOK=ON				\
%else
	-DUSE_FSAL_SHOOK=OFF				\
%endif
%if %{with_fsal_gpfs} 
	-DUSE_FSAL_GPFS=ON				\
%else
	-DUSE_FSAL_GPFS=OFF				\
%endif
%if %{with_fsal_gpfs} 
	-DUSE_FSAL_HPSS=ON				\
%else
	-DUSE_FSAL_HPSS=OFF				\
%endif
%if %{with_fsal_gpfs} 
	-DUSE_FSAL_PT=ON				\
%else
	-DUSE_FSAL_PT=OFF				\
%endif
	-DUSE_FSAL_VFS=ON				\
	-DUSE_FSAL_PROXY=ON				\
	-DUSE_DBUS_STAT=ON				\
	-DUSE_DBUS=ON					\
	-DDISTNAME_HAS_GIT_DATA=OFF

make %{?_smp_mflags} || make %{?_smp_mflags} || make

%install
mkdir -p %{buildroot}%{_sysconfdir}/ganesha/
mkdir -p %{buildroot}%{_sysconfdir}/dbus-1/system.d
mkdir -p %{buildroot}%{_sysconfdir}/sysconfig
mkdir -p %{buildroot}%{_sysconfdir}/logrotate.d
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_sbindir}
mkdir -p %{buildroot}%{_libdir}/ganesha
install -m 644 config_samples/logrotate_ganesha		%{buildroot}%{_sysconfdir}/logrotate.d/ganesha
install -m 644 scripts/ganeshactl/org.ganesha.nfsd.conf	%{buildroot}%{_sysconfdir}/dbus-1/system.d
install -m 755 ganesha.sysconfig			%{buildroot}%{_sysconfdir}/sysconfig/ganesha
install -m 755 tools/mount.9P				%{buildroot}%{_sbindir}/mount.9P

install -m 644 config_samples/ganesha.conf		%{buildroot}%{_sysconfdir}/ganesha

%if 0%{?fedora} 
mkdir -p %{buildroot}%{_unitdir}
install -m 644 scripts/systemd/nfs-ganesha.service	%{buildroot}%{_unitdir}/nfs-ganesha.service
%endif

%if 0%{?rhel}
mkdir -p %{buildroot}%{_sysconfdir}/init.d
install -m 755 ganesha.init				%{buildroot}%{_sysconfdir}/init.d/nfs-ganesha
%endif 


make install


%files
%defattr(-,root,root,-)
%{_bindir}/*
%config %{_sysconfdir}/dbus-1/system.d/org.ganesha.nfsd.conf
%config %{_sysconfdir}/sysconfig/ganesha
%config(noreplace) %{_sysconfdir}/logrotate.d/ganesha
%dir %{_sysconfdir}/ganesha/
%config(noreplace) %{_sysconfdir}/ganesha/ganesha.conf

%if 0%{?fedora} 
%config %{_unitdir}/nfs-ganesha.service
%endif
 
%if 0%{?rhel}
%config %{_sysconfdir}/init.d/nfs-ganesha
%endif

%files mount-9P
%defattr(-,root,root,-)
%{_sbindir}/mount.9P


%files vfs
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsalvfs*


%files nullfs
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsalnull*


%files proxy
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsalproxy*

# Optionnal packages
%if %{with_fsal_gpfs}
%files gpfs
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsalgpfs*
%endif

%if %{with_fsal_zfs}
%files zfs
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsalzfs*
%endif

%if %{with_fsal_xfs}
%files xfs
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsalxfs*
%endif

%if %{with_fsal_ceph}
%files ceph
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsalceph*
%endif

%if %{with_fsal_lustre}
%files lustre 
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsallustre*
%endif

%if %{with_fsal_shook}
%files shook
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsalshook*
%endif

%if %{with_fsal_gluster}
%files gluster
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsalgluster*
%endif

%if %{with_fsal_hpss}
%files hpss 
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsalhpss*
%endif

%if %{with_fsal_pt}
%files pt
%defattr(-,root,root,-)
%{_libdir}/ganesha/libfsalpt*
%endif


%changelog
* Thu Nov 21 2013  Philippe DENIEL <philippe.deniel@cea.fr> 2.O
- bunches of cool new stuff 

