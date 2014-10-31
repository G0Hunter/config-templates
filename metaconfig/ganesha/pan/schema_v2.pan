declaration template metaconfig/ganesha/schema_v2;

# the defaults are based on the GPFS FSAL

final variable GANESHA_V2_LOG_COMPONENTS = list(
'ALL', 'LOG', 'LOG_EMERG', 'MEMLEAKS', 'FSAL', 'NFSPROTO', 
'NFS_V4', 'EXPORT', 'FILEHANDLE', 'DISPATCH', 'CACHE_INODE', 
'CACHE_INODE_LRU', 'HASHTABLE', 'HASHTABLE_CACHE', 'DUPREQ', 
'INIT', 'MAIN', 'IDMAPPER', 'NFS_READDIR', 'NFS_V4_LOCK', 
'CONFIG', 'CLIENTID', 'SESSIONS', 'PNFS', 'RW_LOCK', 'NLM', 
'RPC', 'NFS_CB', 'THREAD', 'NFS_V4_ACL', 'STATE', '9P', 
'9P_DISPATCH', 'FSAL_UP', 'DBUS'
);


type ganesha_v2_9p = {
    "_9P_RDMA_Backlog" ? long(0..) = 10
    "_9P_RDMA_Inpool_size" ? long(0..) = 64
    "_9P_RDMA_Msize" ? long(0..) = 1048576
    "_9P_RDMA_Outpool_Size" ? long(0..) = 32
    "_9P_RDMA_Port" ? long(0..) = 5640
    "_9P_TCP_Msize" ? long(0..) = 65536
    "_9P_TCP_Port" ? long(0..) = 564
};
type ganesha_v2_cacheinode = {
    "Attr_Expiration_Time" ? long = 60
    "Biggest_Window" ? long(0..) = 40
    "Cache_FDs" ? boolean = true
    "Entries_HWMark" ? long(0..) = 100000
    "FD_HWMark_Percent" ? long(0..) = 90
    "FD_LWMark_Percent" ? long(0..) = 50
    "FD_Limit_Percent" ? long(0..) = 99
    "Futility_Count" ? long(0..) = 8
    "LRU_Run_Interval" ? long(0..) = 90
    "NParts" ? long(0..) = 7
    "Reaper_Work" ? long(0..) = 1000
    "Required_Progress" ? long(0..) = 5
    "Retry_Readdir" ? boolean = false
    "Use_Getattr_Directory_Invalidation" ? boolean = false
};
type ganesha_v2_export_FSAL = {
    "name" : string
    "FSAL" ? ganesha_v2_export_FSAL
    #FSAL_VFS
    "pnfs" ? boolean = false
    "fsid_type" ? string with match(SELF, '^(None|One64|Major64|Two64|uuid|Two32|Dev|Device)$')
    #FSAL_GLUSTER
    "glfs_log" ? string = "/tmp/gfapi.log"
    "hostname" : string 
    "volpath" ? string = "/"
    "volume" : string 
    #FSAL_ZFS
    "pool_path" ? string 
    #FSAL_PT
    "pt_export_id" ? long = 1
};

type ganesha_v2_protocol = string with match(SELF, '^(3|4|NFS3|NFS4|V3|V4|NFSv4|NFSv4|9P)$');
type ganesha_v2_SecType = string with match(SELF, '^(none|sys|krb5|krb5i|krb5p)$');
type ganesha_v2_Transports =string with match(SELF, '^(UDP|TCP)$');

type ganesha_v2_export_permissions = {
    "Access_Type" ? string = 'None' with match(SELF, '^(None|RW|RO|MDONLY|MDONLY_RO)$')
    "Anonymous_gid" ? long = -2
    "Anonymous_uid" ? long = -2
    "Delegations" ? string with match(SELF, '^(None|read|write|readwrite|r|w|rw)$')
    "Disable_ACL" ? boolean = false
    "Manage_Gids" ? boolean = false
    "NFS_Commit" ? boolean = false
    "PrivilegedPort" ? boolean = false
    "Protocols" ? ganesha_v2_protocol[] = list('3', '4', '9P')
    "SecType" ? ganesha_v2_SecType[] = list('none', 'sys')
    "Squash" ? string = "root_squash" with match(SELF, 
        '^(root|root_squash|rootsquash|all|all_squash|allsquash|no_root_squash|none|noidsquash)$')
    "Transports" ? ganesha_v2_Transports[] = list('UDP', 'TCP')
};

type ganesha_v2_export_client = {
    include ganesha_v2_export_permissions
    "Clients" : string 
};
type ganesha_v2_exports = {
    include ganesha_v2_export_permissions
    "Attr_Expiration_Time" ? long = 60
    "CLIENT" ? ganesha_v2_export_client[] # the first applicable CLIENT block is used
    "Export_id" : long(0..) # = 1
    "FSAL" : ganesha_v2_export_FSAL
    "Filesystem_id" ? string = "666.666"
    "MaxOffsetRead" ? long(0..) 
    "MaxOffsetWrite" ? long(0..)
    "MaxRead" ? long(0..) = 67108864
    "MaxWrite" ? long(0..) = 67108864
    "Name" ? string
    "Path" : string 
    "PrefRead" ? long(0..) = 67108864
    "PrefReaddir" ? long(0..) = 16384
    "PrefWrite" ? long(0..) = 67108864
    "Pseudo" : string
    "Tag" ? string
    "UseCookieVerifier" ? boolean = true
};

function is_ganesha_v2_log_Components = {
    components = ARGV[0];
    foreach(cmp;logl; components) {
        if(index(cmp, GANESHA_V2_LOG_COMPONENTS)  == -1) {
            error(format("%s is not a valid Ganesha Log Component !", cmp));
            return(false);
        };
    };
};
type ganesha_v2_log_Components = ganesha_v2_log_level{} with is_ganesha_v2_log_Components(SELF);

type ganesha_v2_log_time_format = string with match(SELF, 
    '^(ganesha|true|local|8601|ISO-8601|ISO 8601|ISO|syslog|syslog_usec|false|none|user_defined)$');

type ganesha_v2_log_Format = {
    "CLIENTIP" ? boolean = false
    "COMPONENT" ? boolean = true
    "EPOCH" ? boolean = true
    "FILE_NAME" ? boolean = true
    "FUNCTION_NAME" ? boolean = true
    "HOSTNAME" ? boolean = true
    "LEVEL" ? boolean = true
    "LINE_NUM" ? boolean = true
    "PID" ? boolean = true
    "PROGNAME" ? boolean = true
    "THREAD_NAME" ? boolean = true
    "date_format" ? ganesha_v2_log_time_format = 'ganesha'
    "time_format" ? ganesha_v2_log_time_format = 'ganesha'
    "user_date_format" ? string 
    "user_time_format" ? string

};

type ganesha_v2_log_level = string with match(SELF, 
    '^(NULL|FATAL|MAJ|CRIT|WARN|EVENT|INFO|DEBUG|MID_DEBUG|M_DBG|FULL_DEBUG|F_DBG)$');

type ganesha_v2_log_Facility = {
    "destination" : string 
    "enable" ? string = 'idle' with match(SELF, '^(idle|active|default)$')
    "headers" ? string = 'all' with match(SELF, '^(none|component|all)$')
    "max_level" ? ganesha_v2_log_level = 'FULL_DEBUG'
    "name" ? string 
};

type ganesha_v2_log = {
    "Components" ? ganesha_v2_log_Components
    "Default_log_level" ? ganesha_v2_log_level = 'EVENT'
    "Facility" ? type_ganesha_v2_log_Facility[]
    "Format" ? type_ganesha_v2_log_Format
};

type ganesha_v2_nfs_ip_name = {
    "Expiration_Time" ? long(0..) = 3600
    "Index_Size" ? long(1..51) = 17
};

type ganesha_v2_nfs_krb5 = {
    "Active_krb5" ? boolean = true
    "CCacheDir" ? string = "/var/run/ganesha"
    "KeytabPath" ? string = ""
    "PrincipalName" ? string = "nfs"
};

type ganesha_v2_nfsv4 = {
    "Allow_Numeric_Owners" ? boolean = true
    "Delegations" ? boolean = false
    "DomainName" ? string = "localdomain"
    "FSAL_Grace" ? boolean = false
    "Grace_Period" ? long(0..180) = 90
    "Graceless" ? boolean = false
    "IdmapConf" ? string = "/etc/idmapd.conf"
    "Lease_Lifetime" ? long(0..120) = 60
    "UseGetpwnam" ? boolean # default false if using idmap, true otherwise
};

type ganesha_v2_nfs_core_param = {
    "Bind_Addr" ? type_ip = "0.0.0.0"
    "Clustered" ? boolean = true
    "DRC_Disabled" ? boolean = false
    "DRC_TCP_Cachesz" ? long(1..255) = 127
    "DRC_TCP_Checksum" ? boolean = true
    "DRC_TCP_Hiwat" ? long(1..256) = 64
    "DRC_TCP_Npart" ? long(1..100) = 7
    "DRC_TCP_Recycle_Expire_S" ? long(0..) = 600
    "DRC_TCP_Recycle_Npart" ? long(1..20) = 7
    "DRC_TCP_Size" ? long(1..) = 1024
    "DRC_UDP_Cachesz" ? long(1..) = 599
    "DRC_UDP_Checksum" ? boolean = true
    "DRC_UDP_Hiwat" ? long(1..256) = 16384
    "DRC_UDP_Npart" ? long(1..100) = 7
    "DRC_UDP_Size" ? long(0..) = 32768
    "Decoder_Fridge_Block_Timeout" ? long(0..) = 600
    "Decoder_Fridge_Expiration_Delay" ? long(0..) = 600
    "Dispatch_Max_Reqs" ? long(0..) = 5000
    "Dispatch_Max_Reqs_Xprt" ? long(0..) = 512
    "Drop_Delay_Errors" ? boolean = false
    "Drop_IO_Errors" ? boolean = false
    "Drop_Inval_Errors" ? boolean = false
    "Enable_Fast_Stats" ? boolean = false
    "Enable_NLM" ? boolean = true
    "Enable_RQUOTA" ? boolean = true
    "MNT_Port" ? long(0..) = 0
    "MNT_Program" ? long(1..) = 100005
    "Manage_Gids_Expiration" ? long = 30*60
    "MaxRPCRecvBufferSize" ? long(0..) = 1048576
    "MaxRPCSendBufferSize" ? long(0..) = 1048576
    "NFS_Port" ? long(0..) = 2049
    "NFS_Program" ? long(1..) = 100003
    "NFS_Protocols" ? long(3..4)[] = list(3,4)
    "NLM_Port" ? long(0..) = 0
    "NLM_Program" ? long(1..) = 100021
    "NSM_Use_Caller_Name" ? boolean = false
    "Nb_Worker" ? long(0..) = 16
    "Plugins_Dir" ? string = "/usr/lib64/ganesha"
    "RPC_Debug_Flags" ? long(0..) = 0
    "RPC_Idle_Timeout_S" ? long(0..) = 300
    "RPC_Ioq_ThrdMax" ? long(0..) = 200
    "RPC_Max_Connections" ? long(0..) = 1024
    "Rquota_Port" ? long(0..) = 0
    "Rquota_Program" ? long(1..) = 100011
};

type ganesha_v2_proxy_remote_server = {
    "Active_krb5" ? boolean = false
    "Credential_LifeTime" ? long(0..) = 86400
    "Enable_Handle_Mapping" ? boolean = false
    "HandleMap_DB_Count" ? long(0..) = 8
    "HandleMap_DB_Dir" ? string = "/var/ganesha/handlemap"
    "HandleMap_HashTable_Size" ? long(0..) = 103
    "HandleMap_Tmp_Dir" ? string = "/var/ganesha/tmp"
    "KeytabPath" ? string = "/etc/krb5.keytab"
    "NFS_Port" ? long(0..) = 2049
    "NFS_RecvSize" ? long(0..) = 32768
    "NFS_SendSize" ? long(0..) = 32768
    "NFS_Service" ? long(0..) = 100003
    "RPC_Client_Timeout" ? long(0..) = 60
    "Remote_PrincipalName" ? string 
    "Retry_SleepTime" ? long(0..) = 10
    "Sec_Type" ? string = 'krb5' with match(SELF,'^(krb5|krb5i|krb5p)$')
    "Srv_Addr" ? type_ip = "127.0.0.1"
    "Use_Privileged_Client_Port" ? boolean = false
};

type ganesha_v2_fsalsettings_all = {
    "auth_xdev_export" ? boolean = false
    "cansettime" ? boolean = true
    "link_support" ? boolean = true
    "symlink_support" ? boolean = true
    "umask" ? string = 0
    "xattr_access_rights" ? string = '0400'
};

type ganesha_v2_fsalsettings = {
    include ganesha_v2_fsalsettings_all
    "maxread" ? long(0..) = 67108864
    "maxwrite" ? long(0..) = 67108864
};

type ganesha_v2_proxy = {
    include ganesha_v2_fsalsettings
    "remote_server" ? ganesha_v2_proxy_remote_server
};

type ganesha_v2_GPFS = {
    include ganesha_v2_fsalsettings_all
    "delegations" ? boolean = false
    "fsal_trace" ? boolean = true
    "pnfs_file" ? boolean = false   
};

type ganesha_v2_LUSTRE_PNFS_DataServer = {
    "DS_Addr" ? type_ip = "127.0.0.1"
    "DS_Id" ? long(0..) = 1
    "DS_Port" ? long(0..) = 3260
};
 
type ganesha_v2_LUSTRE_PNFS = {
    "DataServer" ? ganesha_v2_LUSTRE_PNFS_DataServer
    "Stripe_Size" ? long(0..) = 65536
    "Stripe_Width" ? long(0..128) = 8
};

type ganesha_v2_LUSTRE = {
    include ganesha_v2_fsalsettings
    "pnfs" ? ganesha_v2_LUSTRE_PNFS
};

type ganesha_v2_VFS = {
    include ganesha_v2_fsalsettings
};

type ganesha_v2_XFS = {
    include ganesha_v2_fsalsettings
};

type ganesha_v2_PT = {
    include ganesha_v2_fsalsettings
};

type ganesha_v2_ZFS = {
    include ganesha_v2_fsalsettings
};

type ganesha_v2_config = {
    "main" ? ganesha_v2_config_sections
    "exports" : ganesha_v2_exports[]
};

type ganesha_v2_config_sections = {
    "NFS_CORE_PARAM" ? ganesha_v2_nfs_core_param
    "NFS_IP_NAME" ? ganesha_v2_nfs_ip_name
    "NFS_KRB5" ? ganesha_v2_nfs_krb5
    "NFSV4" ? ganesha_v2_nfsv4
    "EXPORT_DEFAULTS" ? ganesha_v2_export_permissions
    "LOG" ? ganesha_v2_log
    "_9P" ? ganesha_v2_9p
    "CACHEINODE" ? ganesha_v2_cacheinode
    "GPFS" ? ganesha_v2_GPFS
    "LUSTRE" ? ganesha_v2_LUSTRE
    "VFS" ? ganesha_v2_VFS
    "XFS" ? ganesha_v2_XFS
    "PT" ?  ganesha_v2_PT
    "ZFS" ? ganesha_v2_ZFS
    "PROXY" ? ganesha_v2_proxy
};

