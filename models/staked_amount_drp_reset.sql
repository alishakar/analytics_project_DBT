-- this models back-fill and forward-fill staked_amount and daily_reward_per_unit as mentioned in 6.1
select staking_date, end_date, contract_id, asset_reward, asset_hold, 
case
    -- back-fill
    when grp = 0 then 0
    -- forward-fill
    else Max(staked_amount) over (partition by contract_id, grp)
end as staked_amount,
case
    -- back-fill
    when grp = 0 then 0
    -- forward-fill
    else Max(daily_reward_per_unit) over (partition by contract_id, grp)
end as daily_reward_per_unit,
reward_amount
from (
    select *,
    COUNT(staked_amount) OVER (partition by contract_id ORDER BY staking_date asc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS grp
    from {{ ref('staking_rates_with_expected_rewards') }}
) as ranked