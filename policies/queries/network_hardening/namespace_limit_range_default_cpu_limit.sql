WITH default_limit_range AS (SELECT namespace,
                                    k8s_core_limit_range_limits.default AS default_limit -- noqa
                             FROM k8s_core_limit_range_limits
                                      JOIN k8s_core_limit_ranges
                                           ON k8s_core_limit_ranges.cq_id =
                                              k8s_core_limit_range_limits.limit_range_cq_id)

INSERT
INTO k8s_policy_results (resource_id, execution_time, framework, check_id, title, context, namespace,
                        resource_name, status)
select uid                                     AS resource_id,
       :'execution_time'::timestamp            AS execution_time,
       :'framework'                            AS framework,
       :'check_id'                             AS check_id,
       'Namespaces CPU default resource limit' AS title,
       context                                 AS context,
       name                                    AS namespace,
       name                                    AS resource_name,
       CASE
           WHEN
               default_limit ->> 'cpu' IS NULL
               THEN 'fail'
           ELSE 'pass'
           END                                 AS status
FROM k8s_core_namespaces
         LEFT JOIN default_limit_range
                   ON default_limit_range.namespace = k8s_core_namespaces.name