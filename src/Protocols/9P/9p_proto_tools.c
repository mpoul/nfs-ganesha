/*
 * vim:noexpandtab:shiftwidth=8:tabstop=8:
 *
 * Copyright CEA/DAM/DIF  (2011)
 * contributeur : Philippe DENIEL   philippe.deniel@cea.fr
 *                Thomas LEIBOVICI  thomas.leibovici@cea.fr
 *
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
 *
 * ---------------------------------------
 */

/**
 * \file    9p_proto_tools.c
 * \brief   9P version
 *
 * 9p_proto_tools.c : _9P_interpretor, protocol's service functions
 *
 */

#include "config.h"
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include <sys/types.h>
#include <pwd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "nfs_core.h"
#include "log.h"
#include "9p.h"
#include "idmapper.h"
#include "uid2grp.h"
#include "export_mgr.h"

int _9p_init(_9p_parameter_t *pparam)
{
	uid2grp_cache_init();
	return 0;
}				/* _9p_init */

int _9p_tools_get_req_context_by_uid(u32 uid, struct _9p_fid *pfid)
{
	struct group_data group_data;
	struct group_data *pgrpdata = &group_data;

	if (!uid2grp(uid, &pgrpdata))
		return -ENOENT;

	pfid->ucred.caller_uid = pgrpdata->uid;
	pfid->ucred.caller_gid = pgrpdata->gid;
	pfid->ucred.caller_glen = pgrpdata->nbgroups;
	pfid->ucred.caller_garray = pgrpdata->pgroups;

	pfid->op_context.creds = &pfid->ucred;
	pfid->op_context.caller_addr = NULL;	/* Useless for 9P, we'll see
						 * if daemon crashes... */
	pfid->op_context.req_type = _9P_REQUEST;

	return 0;
}				/* _9p_tools_get_fsal_cred */

int _9p_tools_get_req_context_by_name(int uname_len, char *uname_str,
				      struct _9p_fid *pfid)
{
	struct gsh_buffdesc name = {
		.addr = uname_str,
		.len = uname_len
	};
	struct group_data group_data;
	struct group_data *pgrpdata = &group_data;

	if (!name2grp(&name, &pgrpdata))
		return -ENOENT;

	pfid->ucred.caller_uid = pgrpdata->uid;
	pfid->ucred.caller_gid = pgrpdata->gid;
	pfid->ucred.caller_glen = pgrpdata->nbgroups;
	pfid->ucred.caller_garray = pgrpdata->pgroups;

	pfid->op_context.creds = &pfid->ucred;
	pfid->op_context.caller_addr = NULL;	/* Useless for 9P, we'll see
						 * if daemon crashes... */
	pfid->op_context.req_type = _9P_REQUEST;

	return 0;
}				/* _9p_tools_get_fsal_cred */

int _9p_tools_errno(cache_inode_status_t cache_status)
{
	int rc = 0;

	switch (cache_status) {
	case CACHE_INODE_SUCCESS:
		rc = 0;
		break;

	case CACHE_INODE_MALLOC_ERROR:
		rc = ENOMEM;
		break;

	case CACHE_INODE_NOT_A_DIRECTORY:
		rc = ENOTDIR;
		break;

	case CACHE_INODE_ENTRY_EXISTS:
		rc = EEXIST;
		break;

	case CACHE_INODE_DIR_NOT_EMPTY:
		rc = ENOTEMPTY;
		break;

	case CACHE_INODE_NOT_FOUND:
		rc = ENOENT;
		break;

	case CACHE_INODE_IS_A_DIRECTORY:
		rc = EISDIR;
		break;

	case CACHE_INODE_FSAL_EPERM:
	case CACHE_INODE_FSAL_ERR_SEC:
		rc = EPERM;
		break;

	case CACHE_INODE_INVALID_ARGUMENT:
	case CACHE_INODE_NAME_TOO_LONG:
	case CACHE_INODE_INCONSISTENT_ENTRY:
	case CACHE_INODE_FSAL_ERROR:
	case CACHE_INODE_BAD_TYPE:
	case CACHE_INODE_STATE_CONFLICT:
	case CACHE_INODE_STATE_ERROR:
	case CACHE_INODE_POOL_MUTEX_INIT_ERROR:
	case CACHE_INODE_INIT_ENTRY_FAILED:
		rc = EINVAL;
		break;

	case CACHE_INODE_NO_SPACE_LEFT:
		rc = ENOSPC;
		break;

	case CACHE_INODE_READ_ONLY_FS:
		rc = EROFS;
		break;

	case CACHE_INODE_FSAL_ESTALE:
	case CACHE_INODE_DEAD_ENTRY:
		rc = ESTALE;
		break;

	case CACHE_INODE_QUOTA_EXCEEDED:
		rc = EDQUOT;
		break;

	case CACHE_INODE_IO_ERROR:
	case CACHE_INODE_ASYNC_POST_ERROR:
	case CACHE_INODE_GET_NEW_LRU_ENTRY:
	case CACHE_INODE_LRU_ERROR:
	case CACHE_INODE_HASH_SET_ERROR:
	case CACHE_INODE_INSERT_ERROR:
	case CACHE_INODE_HASH_TABLE_ERROR:
		rc = EIO;
		break;

	case CACHE_INODE_NOT_SUPPORTED:
		rc = ENOTSUP;
		break;

	case CACHE_INODE_FSAL_EACCESS:
		rc = EACCES;
		break;

	case CACHE_INODE_DELAY:
		rc = EAGAIN;
		break;

	default:
		rc = EIO;
		break;
	}

	return rc;
}				/* _9p_tools_errno */

void _9p_tools_fsal_attr2stat(struct attrlist *pfsalattr, struct stat *pstat)
{
	/* zero output structure */
	memset((char *)pstat, 0, sizeof(struct stat));

	pstat->st_dev = 0;	/* Omitted in 9P */
	pstat->st_ino = pfsalattr->fileid;

	pstat->st_mode = pfsalattr->mode;
	if (pfsalattr->type == DIRECTORY)
		pstat->st_mode |= __S_IFDIR;
	if (pfsalattr->type == REGULAR_FILE)
		pstat->st_mode |= __S_IFREG;
	if (pfsalattr->type == SYMBOLIC_LINK)
		pstat->st_mode |= __S_IFLNK;
	if (pfsalattr->type == SOCKET_FILE)
		pstat->st_mode |= __S_IFSOCK;
	if (pfsalattr->type == BLOCK_FILE)
		pstat->st_mode |= __S_IFBLK;
	if (pfsalattr->type == CHARACTER_FILE)
		pstat->st_mode |= __S_IFCHR;
	if (pfsalattr->type == FIFO_FILE)
		pstat->st_mode |= __S_IFIFO;

	pstat->st_nlink = (u32) pfsalattr->numlinks;
	pstat->st_uid = pfsalattr->owner;
	pstat->st_gid = pfsalattr->group;
	pstat->st_rdev = pfsalattr->rawdev.major;
	pstat->st_size = pfsalattr->filesize;
	pstat->st_blksize = 4096;
	pstat->st_blocks = (pfsalattr->filesize / 4096) + 1;
	pstat->st_atime = pfsalattr->atime.tv_sec;
	pstat->st_mtime = pfsalattr->mtime.tv_sec;
	pstat->st_ctime = pfsalattr->ctime.tv_sec;

}				/* _9p_tools_fsal_attr2stat */

void _9p_tools_acess2fsal(u32 *paccessin, fsal_accessflags_t *pfsalaccess)
{
	memset((char *)pfsalaccess, 0, sizeof(fsal_accessflags_t));

	if (*paccessin & O_WRONLY)
		*pfsalaccess |= FSAL_W_OK;
	if (*paccessin & O_RDONLY)
		*pfsalaccess |= FSAL_R_OK;
	if (*paccessin & O_RDWR)
		*pfsalaccess |= FSAL_R_OK | FSAL_W_OK;
}				/* _9p_tools_acess2fsal */

void _9p_chomp_attr_value(char *str, size_t size)
{
	int len;

	if (str == NULL)
		return;

	/* security: set last char to '\0' */
	str[size - 1] = '\0';

	len = strnlen(str, size);
	if ((len > 0) && (str[len - 1] == '\n'))
		str[len - 1] = '\0';
}

void _9p_openflags2FSAL(u32 *inflags, fsal_openflags_t *outflags)
{
	if (inflags == NULL || outflags == NULL)
		return;

	if (*inflags & O_WRONLY)
		*outflags |= FSAL_O_WRITE;
	if (*inflags & O_RDWR)
		*outflags |= FSAL_O_RDWR;
	/* Exception: O_RDONLY is 0, it can't be tested with a logical and */
	/* We consider that non( has O_WRONLY or has O_RDWR ) is RD_ONLY */
	if (!(*inflags & (O_WRONLY | O_RDWR)))
		*outflags = FSAL_O_READ;

	return;
}				/* _9p_openflags2FSAL */

/**
 * @brief Free this fid after releasing its resources.
 *
 * @param pfid   [IN] pointer to fid entry
 * @param fid    [IN] pointer to fid acquired from message
 * @param req9p [IN] pointer to request data
 */
static void free_fid(struct _9p_fid *pfid)
{
	struct gsh_export *exp;

	cache_inode_put(pfid->pentry);
	if (pfid->from_attach) {
		exp = container_of(pfid->export, struct gsh_export, export);
		put_gsh_export(exp);
	}
	gsh_free(pfid);
}

int _9p_tools_clunk(struct _9p_fid *pfid)
{
	fsal_status_t fsal_status;
	cache_inode_status_t cache_status;

	/* If the fid is related to a xattr, free the related memory */
	if (pfid->specdata.xattr.xattr_content != NULL &&
	    pfid->specdata.xattr.xattr_write == TRUE) {
		/* Check size give at TXATTRCREATE with
		 * the one resulting from the writes */
		if (pfid->specdata.xattr.xattr_size !=
		    pfid->specdata.xattr.xattr_offset) {
			free_fid(pfid);
			return EINVAL;
		}

		/* Do we handle system.posix_acl_access */
		if (pfid->specdata.xattr.xattr_id == ACL_ACCESS_XATTR_ID) {
			fsal_status =
			    pfid->pentry->obj_handle->ops->setextattr_value(
				    pfid->pentry->obj_handle,
				    &pfid->op_context,
				    "system.posix_acl_access",
				    pfid->specdata.xattr.xattr_content,
				    pfid->specdata.xattr.xattr_size,
				    FALSE);
		} else {
			/* Write the xattr content */
			fsal_status =
			    pfid->pentry->obj_handle->ops->
				setextattr_value_by_id(pfid->pentry->obj_handle,
						       &pfid->op_context,
						       pfid->specdata.xattr.
						       xattr_id,
						       pfid->specdata.xattr.
						       xattr_content,
						       pfid->specdata.xattr.
						       xattr_size);
			if (FSAL_IS_ERROR(fsal_status)) {
				free_fid(pfid);
				gsh_free(pfid->specdata.xattr.xattr_content);
				return _9p_tools_errno(
					   cache_inode_error_convert(
					       fsal_status));
			}
		}
	}
	gsh_free(pfid->specdata.xattr.xattr_content);

	/* If object is an opened file, close it */
	if ((pfid->pentry->type == REGULAR_FILE) && is_open(pfid->pentry)) {
		if (pfid->opens) {
			cache_inode_dec_pin_ref(pfid->pentry, FALSE);
			pfid->opens = 0;	/* dead */

			/* Under this flag, pin ref is still checked */
			cache_status =
			    cache_inode_close(pfid->pentry,
					      CACHE_INODE_FLAG_REALLYCLOSE);
			if (cache_status != CACHE_INODE_SUCCESS) {
				free_fid(pfid);
				return _9p_tools_errno(cache_status);
			}
			cache_status =
			    cache_inode_refresh_attrs_locked(pfid->pentry,
							     &pfid->op_context);
			if (cache_status != CACHE_INODE_SUCCESS
			    && cache_status != CACHE_INODE_FSAL_ESTALE) {
				free_fid(pfid);
				return _9p_tools_errno(cache_status);
			}
		}
	}

	free_fid(pfid);
	return 0;
}

void _9p_cleanup_fids(struct _9p_conn *conn)
{
	int i;
	for (i = 0; i < _9P_FID_PER_CONN; i++) {
		if (conn->fids[i]) {
			_9p_tools_clunk(conn->fids[i]);
			conn->fids[i] = NULL;	/* poison the entry */
		}
	}
}
