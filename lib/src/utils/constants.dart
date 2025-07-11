const loggedIn = "loggedin";
const lastLogoutTime = "lastLogoutTime";
const bearerToken = "bearerToken";
const firstCall = "firstCall";
const MERCHANT_ID = "merchantId";
const USERNAME = "username";
const USER_AVATAR = "avatar";
const USER_NAME_ERROR = "Minimum 3 and maximum 10 characters allowed.";
const PASSWORD_ERROR = "Minimum 3 and maximum 10 characters allowed.";
const SOMETHING_WENT_WRONG = "Something went wrong";
const NO_MORE_RECORDS = "No more results";

// const BASE_URL = "https://posweb.outerbox.net";
const PROD_URL = "https://pos.outerboxcloud.com";
// const PROD_URL = "https://francos.store";
//const BASE_URL = "https://posstaging.outerboxcloud.com";
const GRANT_TYPE = "password";
const CLIENT_ID = "2";
const CLIENT_SECRET_PROD = "n2bCBm58uRePOEkcXG8xmtHFy8ARyMQNbgGvS47j";
// const CLIENT_SECRET_PROD = "WU8Ld5cl0U0m1loa4wXiTbmP3QCuYDXpgxXPdVk4";

// const TOKEN = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYjRmMGI2NjU5MzgxYTM5OWUxNTVkZjEyNjUyY2ZkYTM5OTFlODg1ZTdiOWVjMjg2ZjhlOTlhNTE1OTUwMjk3NWMyNzhkOTgwMTM5Y2NlNGMiLCJpYXQiOjE2MTI3NjU1MTYsIm5iZiI6MTYxMjc2NTUxNiwiZXhwIjoyMTgwNzU5MTE2LCJzdWIiOiIiLCJzY29wZXMiOltdfQ.VZx71bUT-SVtYQxAJ7f_lzFIbMcefbU_dlPyi76MSVcmplkRmYXUeimAD4T2JhDDfB7K4-AVQIZkKBXdTlt8ypCOWBvK3f87OV3zl-dEjArV6rsVVi8dIcQaWNGrGPSf0_EyAltbVhOY9fQb_p7OEPgpz38l0m0rwD9mRnc6GUE4mjs6gL1uvRvt8gck0PLqkhCNfQ5aAon7Wktqd5j_so7TeeMo-CeO1ni7-INV3Zjllgl_hHUy7u69F-BEexPxEw8f-og8INp-NT9E7NHOaJ5xCavONeP8ewfHeBuAmb9vA-aswyHSj1yzkEBMQysnhiEOUKueQvM3FE6xXnF5RNqQKtDBx4vF4hK7jM5y5-23OnizbmE4x-D9caWeHabGpz732td3O0jPMk59PjXI3wKBJOp8gfLwMAw4SGMvv7ANg6k_f-Dnt1MDLIFC2oWZJ01hCX4BDnDOw--yRBkab1SE4lWrv764izOayVMQcBt7GtNivemu_luNODv7UYyxma6jEeuViTOq91oIfrJJrV_wsBdGvt2ui_hhi_49Rld2htN0YNHzWUN-EXjZQMCt0QxZ7B34L046C1eO8qLwd9Fq1iMKqh580y7Jp5D_Mpg2L-3Su0WiVtfM7gjpFD_aJqBYte3uTNDCQO-qA8CMcfOs_JydpxLOG2k9kHNu3Y8";
const TOKEN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIyIiwianRpIjoiNmE5OGYxZDFkZGQ1ZGExYWZhNGJkZjgzYzRjNGY5OWRhYmQyNmY0OGI0ODdiM2QxZTFmZDFkNjUwNjFlYjkzZTU5N2ZjODBhY2JjZTIxNmYiLCJpYXQiOjE2MjAzMTUxNjUsIm5iZiI6MTYyMDMxNTE2NSwiZXhwIjoyMTg4MzA4NzY1LCJzdWIiOiJiNzUxM2ZiYi0yZmU3LTRhMDctODA4Yy01ODVjYWI5ZTU2NGEiLCJzY29wZXMiOltdfQ.XkiWY3mdTIwxwcA9ZYLSv-cotXKIaMWEZWuZEQiEyjbTpwRQBGAIZDcVm7pyq1r1iIGO83M6jMpTvn6PzP22BuFM_VagokFfgQ5K5k_6GKAREcxsRQv2j0u3V8_Z5KmQJY3kIF5QHqZCJLrgVmsm5Dn4sd0VE825xjq_PrwStSu7n1StRTHB939Sh1qW6H4720MJM-XLQ-GVJFkIYz0vMrCPJf4jXt1JN1dKL2zyjIw8yTtGiSC2bNjlAKausoYFLBo8Vlu8it2scQ3pxTvXR4XPTaWjf2ltJBpBOMRs0qcocdyjnJGcPzfzXGe_slOv9ICHNSDxbuTKolchg02t6Z6OYwsfkEeO6D8AWHyflNX8xza7odhkxfEfCjSGswe68dlQZzUieAH_r624fKeh3jCCQaKjO5UzRB9thRGUdtDwFHOKZC8oloUqKWFN2E-m2frXyTHEryTAyP436mPkqC4kXZku8szIze62qn1kt3CF0BclaTYCj41nZzO7WEMt8DwUwgsZQc9eEe_yWc2fnVFctgS3r_c6dc5YOnPXMctMxWs-Aqguz5yQUqyrLFKiYtKPSSA_LGFG1x3NEliBxja20L0lCvyByxrhxlvyDwjuJJeXw2GJXS7vCCZ8OCJaVZb25mDneDjhShiiloTMX0QyjoB9e9kZsFKZ9_fdRmc";

const APP_ID = "1156508";
const KEY = "1dd91fd94764569af673";
const SECRET = "c32cebd0ce4847399f41";
const CLUSTER = "ap1";
