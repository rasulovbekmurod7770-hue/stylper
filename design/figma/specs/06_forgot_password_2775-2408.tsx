// Figma get_design_context output (verbatim) — node 2775:2408 "Screen-ForgotPassword"
// File: Z6aHsxkD41lT8lZ8JiBsQv, fetched 2026-10-07. Asset URLs are expired; assets live in design/figma/raw/forgot.
const assetPathPrefix = "https://www.figma.com/api/mcp/asset/d52ab715-c950-4b0f-9924-a520ba62fbe0";
const imgIosSignal = `${assetPathPrefix}/8c49b.svg`;
const imgIosWifiSignal = `${assetPathPrefix}/04979.svg`;
const imgIosBatteryFull = `${assetPathPrefix}/4be39.svg`;
const imgArrowLeft = `${assetPathPrefix}/f3e77.svg`;
const imgMail = `${assetPathPrefix}/2866a.svg`;
const imgIcons = `${assetPathPrefix}/41e18.svg`;

export default function ScreenForgotPassword() {
  return (
    <div className="bg-[#fafaf7] content-stretch flex flex-col items-start justify-between overflow-clip relative rounded-[40px] size-full" data-node-id="2775:2408" data-name="Screen-ForgotPassword">
      <div className="content-stretch flex h-[44px] items-center justify-between px-[20px] relative shrink-0 w-full" data-node-id="2775:2409" data-name="StatusBar">
        <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[14px] whitespace-nowrap" data-node-id="2775:2410">
          9:41
        </p>
        <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-node-id="2775:2411" data-name="Icons">
          <div className="h-[10px] relative shrink-0 w-[18px]" data-node-id="2775:2412" data-name="ios-signal">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosSignal} />
          </div>
          <div className="h-[12px] relative shrink-0 w-[16px]" data-node-id="2775:2414" data-name="ios-wifi-signal">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosWifiSignal} />
          </div>
          <div className="h-[12px] relative shrink-0 w-[24px]" data-node-id="2775:2416" data-name="ios-battery-full">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosBatteryFull} />
          </div>
        </div>
      </div>
      <div className="content-stretch flex flex-col gap-[32px] items-start pt-[40px] px-[24px] relative shrink-0 w-full" data-node-id="2775:2418" data-name="Content">
        <div className="bg-[rgba(26,26,26,0.04)] border border-[rgba(26,26,26,0.1)] border-solid content-stretch flex items-center justify-center relative rounded-[12px] shrink-0 size-[44px]" data-node-id="2775:2419" data-name="BackButton">
          <div className="relative shrink-0 size-[20px]" data-node-id="2775:2420" data-name="arrow-left">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgArrowLeft} />
          </div>
        </div>
        <div className="[word-break:break-word] content-stretch flex flex-col gap-[12px] items-start not-italic relative shrink-0 w-full" data-node-id="2775:2422" data-name="Header">
          <p className="font-['Inter:Extra_Bold'] font-extrabold leading-[normal] relative shrink-0 text-[#1a1a1a] text-[28px] tracking-[-0.5px] whitespace-nowrap" data-node-id="2775:2423">
            Forgot password?
          </p>
          <p className="font-['Inter:Regular'] font-normal leading-[1.5] min-w-full relative shrink-0 text-[#807a87] text-[15px] w-[min-content]" data-node-id="2775:2424">{`Enter your email address below and we'll send you a link to reset your password and regain access to your account.`}</p>
        </div>
        <div className="content-stretch flex flex-col gap-[24px] items-start relative shrink-0 w-full" data-node-id="2775:2425" data-name="Form">
          <div className="content-stretch flex flex-col gap-[8px] items-start relative shrink-0 w-full" data-node-id="2775:2426" data-name="Field-Email Address">
            <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[12px] tracking-[0.5px] uppercase whitespace-nowrap" data-node-id="2775:2427">
              Email Address
            </p>
            <div className="bg-[rgba(26,26,26,0.05)] border border-[rgba(26,26,26,0.1)] border-solid content-stretch flex gap-[12px] h-[50px] items-center px-[16px] relative rounded-[12px] shrink-0 w-full" data-node-id="2775:2428" data-name="InputContainer">
              <div className="relative shrink-0 size-[18px]" data-node-id="2775:2429" data-name="mail">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgMail} />
              </div>
              <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Regular'] font-normal leading-[normal] min-w-px not-italic relative text-[15px] text-[rgba(26,26,26,0.3)]" data-node-id="2775:2431">
                developer@stylper.ai
              </p>
            </div>
          </div>
          <div className="bg-[rgba(255,50,91,0.06)] border border-[rgba(255,50,91,0.2)] border-solid content-stretch flex gap-[12px] items-start p-[16px] relative rounded-[12px] shrink-0 w-full" data-node-id="2775:2432" data-name="SecureHint">
            <div className="overflow-clip relative shrink-0 size-[24px]" data-node-id="2775:2433" data-name="Icons">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIcons} />
            </div>
            <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Medium'] font-medium leading-[1.4] min-w-px not-italic relative text-[#ff325b] text-[13px]" data-node-id="2775:2434">
              A secure password reset verification link will be active for 60 minutes.
            </p>
          </div>
        </div>
        <div className="bg-gradient-to-b content-stretch flex from-[var(--stylper-1,#c11e38)] h-[52px] items-center justify-center relative rounded-[14px] shrink-0 to-[#ff627b] w-full" data-node-id="2775:2435" data-name="PrimarySubmit">
          <p className="[word-break:break-word] font-['Inter:Bold'] font-bold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[16px] whitespace-nowrap" data-node-id="2775:2436">
            Send Reset Link
          </p>
        </div>
      </div>
      <div className="content-stretch flex flex-col items-center pb-[12px] relative shrink-0 w-full" data-node-id="2775:2437" data-name="Footer">
        <p className="[word-break:break-word] font-['Inter:Regular'] font-normal leading-[0] not-italic relative shrink-0 text-[#898989] text-[14px] whitespace-nowrap" data-node-id="2775:2438">
          <span className="leading-[normal]">{`Back to `}</span>
          <span className="font-['Inter:Bold'] font-bold leading-[normal] text-[#ff325b]">Sign In</span>
        </p>
      </div>
      <div className="content-stretch flex flex-col h-[34px] items-center justify-end pb-[8px] relative shrink-0 w-full" data-node-id="2775:2439" data-name="HomeIndicatorContainer">
        <div className="bg-[#1a1a1a] h-[5px] opacity-40 relative rounded-[100px] shrink-0 w-[140px]" data-node-id="2775:2440" data-name="HomeIndicator" />
      </div>
    </div>
  );
}
