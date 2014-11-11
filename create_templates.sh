#!/bin/bash -x

#sec_groups=$(neutron security-group-list | grep 'default' | awk '{print $2}')

#for sg in ${sec_groups[@]}
#do
#    neutron security-group-rule-create $sg --direction ingress --protocol tcp --port-range-min 1 --port-range-max 65535 --remote-ip-prefix 0.0.0.0/0
#    neutron security-group-rule-create $sg --direction egress --protocol tcp --port-range-min 1 --port-range-max 65535 --remote-ip-prefix 0.0.0.0/0
#    neutron security-group-rule-create $sg --direction ingress --protocol udp --port-range-min 1 --port-range-max 65535 --remote-ip-prefix 0.0.0.0/0
#    neutron security-group-rule-create $sg --direction egress --protocol udp --port-range-min 1 --port-range-max 65535 --remote-ip-prefix 0.0.0.0/0
#done

FLOATING_IP_POOL=$(neutron net-list | grep 'net04_ext' | awk '{print $2}')
MNG_NETWORK=$(neutron net-list | grep 'net04 ' | awk '{print $2}')
VANILLA_IMAGE_ID="vanilla-image"
HDP_IMAGE_ID="hdp-image"

tmp_file=$(mktemp)

# create vanilla ng templates

sed "s/FLOATING_IP_POOL/$FLOATING_IP_POOL/g" ng_tmpl_vanilla_master.json > $tmp_file
van_master_template_id=$(sahara node-group-template-create --json $tmp_file | grep ' id ' | awk '{print $4}')
cat $tmp_file

sed "s/FLOATING_IP_POOL/$FLOATING_IP_POOL/g" ng_tmpl_vanilla_worker.json > $tmp_file
van_worker_template_id=$(sahara node-group-template-create --json $tmp_file | grep ' id ' | awk '{print $4}')

# create hdp ng templates

sed "s/FLOATING_IP_POOL/$FLOATING_IP_POOL/g" ng_tmpl_hdp_manager.json > $tmp_file
hdp_manager_template_id=$(sahara node-group-template-create --json $tmp_file | grep ' id ' | awk '{print $4}')

sed "s/FLOATING_IP_POOL/$FLOATING_IP_POOL/g" ng_tmpl_hdp_master.json > $tmp_file
hdp_master_template_id=$(sahara node-group-template-create --json $tmp_file | grep ' id ' | awk '{print $4}')

sed "s/FLOATING_IP_POOL/$FLOATING_IP_POOL/g" ng_tmpl_hdp_worker.json > $tmp_file
hdp_worker_template_id=$(sahara node-group-template-create --json $tmp_file | grep ' id ' | awk '{print $4}')

# create cdh ng templates

sed "s/FLOATING_IP_POOL/$FLOATING_IP_POOL/g" ng_tmpl_cdh_manager.json > $tmp_file
cdh_manager_template_id=$(sahara node-group-template-create --json $tmp_file | grep ' id ' | awk '{print $4}')

sed "s/FLOATING_IP_POOL/$FLOATING_IP_POOL/g" ng_tmpl_cdh_master.json > $tmp_file
cdh_master_template_id=$(sahara node-group-template-create --json $tmp_file | grep ' id ' | awk '{print $4}')

sed "s/FLOATING_IP_POOL/$FLOATING_IP_POOL/g" ng_tmpl_cdh_worker.json > $tmp_file
cdh_worker_template_id=$(sahara node-group-template-create --json $tmp_file | grep ' id ' | awk '{print $4}')

# create vanilla cluster tempate

sed -e "s/MASTER_NG_TEMPLATE/$van_master_template_id/g" \
    -e "s/WORKER_NG_TEMPLATE/$van_worker_template_id/g" \
    -e "s/MANAGEMENT_NETWORK/$MNG_NETWORK/g" cl_tmpl_vanilla.json > $tmp_file
sahara cluster-template-create --json $tmp_file

# create hdp cluster template

sed -e "s/MANAGER_NG_TEMPLATE/$hdp_manager_template_id/g" \
    -e "s/MASTER_NG_TEMPLATE/$hdp_master_template_id/g" \
    -e "s/WORKER_NG_TEMPLATE/$hdp_worker_template_id/g" \
    -e "s/MANAGEMENT_NETWORK/$MNG_NETWORK/g" cl_tmpl_hdp.json > $tmp_file
sahara cluster-template-create --json $tmp_file

# create cdh cluster template

sed -e "s/MANAGER_NG_TEMPLATE/$cdh_manager_template_id/g" \
    -e "s/MASTER_NG_TEMPLATE/$cdh_master_template_id/g" \
    -e "s/WORKER_NG_TEMPLATE/$cdh_worker_template_id/g" \
    -e "s/MANAGEMENT_NETWORK/$MNG_NETWORK/g" cl_tmpl_cdh.json > $tmp_file
sahara cluster-template-create --json $tmp_file

# register image

#sahara image-register --id $VANILLA_IMAGE_ID --username ubuntu
#sahara image-register --id $HDP_IMAGE_ID --username cloud-user
#sahara image-add-tag --id $VANILLA_IMAGE_ID --tag vanilla
#sahara image-add-tag --id $VANILLA_IMAGE_ID --tag 2.4.1
#sahara image-add-tag --id $HDP_IMAGE_ID --tag hdp
#sahara image-add-tag --id $HDP_IMAGE_ID --tag 2.0.6
