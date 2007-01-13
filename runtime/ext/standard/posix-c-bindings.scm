;; ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler Runtime Libraries
;; Copyright (C) 2007 Roadsend, Inc.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public License
;; as published by the Free Software Foundation; either version 2.1
;; of the License, or (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Lesser General Public License for more details.
;; 
;; You should have received a copy of the GNU Lesser General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;; ***** END LICENSE BLOCK *****

(module posix-c-bindings
   (extern
    (include "posix-headers.h")
;    (include "grp.h")
;    (include "pwd.h")
    (include "signal.h")
    (include "unistd.h")
;    (include "sys/times.h")
;    (include "sys/utsname.h")
    (include "sys/stat.h")
;    (include "sys/resource.h")
    (include "string.h")
    (include "errno.h")
    (type pid_t int "pid_t")
    (type uid_t uint "uid_t")
    (type gid_t uint "gid_t")
    (type gid_t* (pointer gid_t) "gid_t *")
    (type clock_t long "clock_t")
    (type mode_t uint "mode_t") ; already defined in php-files.scm, what to do?
    (type struct-tms
	  (struct (tms_utime::clock_t "tms_utime")
		  (tms_stime::clock_t "tms_stime")
		  (tms_cutime::clock_t "tms_cutime")
		  (tms_cstime::clock_t "tms_cstime"))
	  "struct tms")
    (type char* (pointer char) "char *")
    (type char** (pointer string) "char **")
    (type struct-group
	  (struct (gr_name::string "gr_name")
		  (gr_passwd::string "gr_passwd")
		  (gr_gid::gid_t "gr_gid")
		  (gr_mem::char** "gr_mem"))
	  "struct group")
    (type struct-passwd
	  (struct (pw_name::string "pw_name")
		  (pw_passwd::string "pw_passwd")
		  (pw_uid::uid_t "pw_uid")
		  (pw_gid::gid_t "pw_gid")
		  (pw_gecos::string "pw_gecos")
		  (pw_dir::string "pw_dir")
		  (pw_shell::string "pw_shell"))
	  "struct passwd")
    (type rlim_t ulong "rlim_t")
    (type struct-rlimit
	  (struct (rlim_cur::rlim_t "rlim_cur")
		  (rlim_max::rlim_t "rlim_max"))
	  "struct rlimit")
    (macro sizeof::long (::void*) "sizeof")
    (macro c-errno::int "errno")
    (macro c-strerror::string (::int) "strerror")
    (macro c-kill::int (::pid_t ::int) "kill")
    (macro c-getpid::pid_t () "getpid")
    (macro c-getppid::pid_t () "getppid")
    (macro c-getuid::uid_t () "getuid")
    (macro c-geteuid::uid_t () "geteuid")
    (macro c-getgid::gid_t () "getgid")
    (macro c-getegid::gid_t () "getegid")
    (macro c-setuid::int (::uid_t) "setuid")
    (macro c-seteuid::int (::uid_t) "seteuid")
    (macro c-setgid::int (::gid_t) "setgid")
    (macro c-setegid::int (::gid_t) "setegid")
    (macro c-ngroups-max::int "NGROUPS_MAX")
    (macro c-getgroups::int (::int ::gid_t*) "getgroups")
    (macro c-getlogin::string () "getlogin")
    (macro c-getpgrp::pid_t () "getpgrp")
    (macro c-setsid::pid_t () "setsid")
    (macro c-setpgid::int (::pid_t ::pid_t) "setpgid")
    (macro c-getpgid::pid_t (::pid_t) "getpgid")
    (macro c-getsid::pid_t (::pid_t) "getsid")
    (macro c-sys_nmln::int "SYS_NMLN") ;max utsname string length
    (macro c-times::clock_t (::struct-tms*) "times")
    (macro c-ctermid::string (::char*) "ctermid")
    (macro c-ttyname::string (::int) "ttyname")
    (macro c-isatty::int (::int) "isatty")
    (macro c-mkfifo::int (::string ::mode_t) "mkfifo")
    (macro c-maxpathlen::int "MAXPATHLEN")
    (macro c-getgrnam::struct-group* (::string) "getgrnam")
    (macro c-getgrgid::struct-group* (::gid_t) "getgrgid")
    (macro c-getpwnam::struct-passwd* (::string) "getpwnam")
    (macro c-getpwuid::struct-passwd* (::uid_t) "getpwuid")
    (macro c-rlimit_cpu::int "RLIMIT_CPU")         ;CPU time in seconds
    (macro c-rlimit_fsize::int "RLIMIT_FSIZE")     ;max filesize 
    (macro c-rlimit_data::int "RLIMIT_DATA")       ;max data size
    (macro c-rlimit_stack::int "RLIMIT_STACK")     ;max stack size
    (macro c-rlimit_core::int "RLIMIT_CORE")       ;max core file size
    (macro c-rlimit_rss::int "RLIMIT_RSS")         ;max resident set size
    (macro c-rlimit_nproc::int "RLIMIT_NPROC")     ;max number of processes
    (macro c-rlimit_nofile::int "RLIMIT_NOFILE")   ;max number of open files 
    (macro c-rlimit_memlock::int "RLIMIT_MEMLOCK") ;max lcked-in-mem addr space
    (macro c-rlimit_as::int "RLIMIT_AS") ;address space (virtual memory) limit
    (macro c-rlim_infinity::int "RLIM_INFINITY") ;if resource is unlimited 
    (macro c-getrlimit::int (::int ::struct-rlimit*) "getrlimit"))) 
