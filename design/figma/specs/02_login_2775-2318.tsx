// Figma get_design_context output (verbatim) — node 2775:2318 "Screen-Login" (Sign in form)
// File: Z6aHsxkD41lT8lZ8JiBsQv, fetched 2026-10-07. Asset URLs are expired; assets live in design/figma/raw/login.
const assetPathPrefix = "https://www.figma.com/api/mcp/asset/46e92956-82e8-45ae-8d8d-8921ba9b2618";
const imgIosSignal = `${assetPathPrefix}/8c49b.svg`;
const imgIosWifiSignal = `${assetPathPrefix}/04979.svg`;
const imgIosBatteryFull = `${assetPathPrefix}/4be39.svg`;
const imgMail = `${assetPathPrefix}/2866a.svg`;
const imgLock = `${assetPathPrefix}/666cd.svg`;
const imgEye = `${assetPathPrefix}/55ca1.svg`;
const imgLineLeft = `${assetPathPrefix}/51409.svg`;
const imgCircleX = `${assetPathPrefix}/21e0e.svg`;
const imgApple = `${assetPathPrefix}/cfab2.svg`;

export default function ScreenLogin() {
  return (
    <div className="bg-[#fafaf7] content-stretch flex flex-col items-start justify-between overflow-clip relative rounded-[40px] size-full" data-node-id="2775:2318" data-name="Screen-Login">
      <div className="content-stretch flex h-[44px] items-center justify-between px-[20px] relative shrink-0 w-full" data-node-id="2775:2319" data-name="StatusBar">
        <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[14px] whitespace-nowrap" data-node-id="2775:2320">
          9:41
        </p>
        <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-node-id="2775:2321" data-name="Icons">
          <div className="h-[10px] relative shrink-0 w-[18px]" data-node-id="2775:2322" data-name="ios-signal">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosSignal} />
          </div>
          <div className="h-[12px] relative shrink-0 w-[16px]" data-node-id="2775:2324" data-name="ios-wifi-signal">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosWifiSignal} />
          </div>
          <div className="h-[12px] relative shrink-0 w-[24px]" data-node-id="2775:2326" data-name="ios-battery-full">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosBatteryFull} />
          </div>
        </div>
      </div>
      <div className="content-stretch flex flex-col gap-[28px] items-start pt-[20px] px-[24px] relative shrink-0 w-full" data-node-id="2775:2328" data-name="Content">
        <div className="[word-break:break-word] content-stretch flex flex-col gap-[8px] items-start not-italic relative shrink-0 w-full" data-node-id="2775:2329" data-name="Header">
          <p className="font-['Inter:Extra_Bold'] font-extrabold leading-[normal] relative shrink-0 text-[#1a1a1a] text-[28px] tracking-[-0.5px] whitespace-nowrap" data-node-id="2775:2330">
            Welcome back
          </p>
          <p className="font-['Inter:Regular'] font-normal leading-[1.4] min-w-full relative shrink-0 text-[#807a87] text-[15px] w-[min-content]" data-node-id="2775:2331">
            Sign in to your account to find your style
          </p>
        </div>
        <div className="content-stretch flex flex-col gap-[16px] items-start relative shrink-0 w-full" data-node-id="2775:2332" data-name="Form">
          <div className="content-stretch flex flex-col gap-[8px] items-start relative shrink-0 w-full" data-node-id="2775:2333" data-name="Field-Email Address">
            <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[12px] tracking-[0.5px] uppercase whitespace-nowrap" data-node-id="2775:2334">
              Email Address
            </p>
            <div className="bg-[rgba(26,26,26,0.05)] border border-[rgba(26,26,26,0.1)] border-solid content-stretch flex gap-[12px] h-[50px] items-center px-[16px] relative rounded-[12px] shrink-0 w-full" data-node-id="2775:2335" data-name="InputContainer">
              <div className="relative shrink-0 size-[18px]" data-node-id="2775:2336" data-name="mail">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgMail} />
              </div>
              <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Regular'] font-normal leading-[normal] min-w-px not-italic relative text-[#1a1a1a] text-[15px]" data-node-id="2775:2338">
                developer@stylper.ai
              </p>
            </div>
          </div>
          <div className="content-stretch flex flex-col gap-[8px] items-start relative shrink-0 w-full" data-node-id="2775:2339" data-name="Field-Password">
            <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[12px] tracking-[0.5px] uppercase whitespace-nowrap" data-node-id="2775:2340">
              Password
            </p>
            <div className="bg-[rgba(26,26,26,0.05)] border border-[rgba(26,26,26,0.1)] border-solid content-stretch flex gap-[12px] h-[50px] items-center px-[16px] relative rounded-[12px] shrink-0 w-full" data-node-id="2775:2341" data-name="InputContainer">
              <div className="relative shrink-0 size-[18px]" data-node-id="2775:2342" data-name="lock">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgLock} />
              </div>
              <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Regular'] font-normal leading-[normal] min-w-px not-italic relative text-[#1a1a1a] text-[15px]" data-node-id="2775:2344">
                ••••••••••••
              </p>
              <div className="relative shrink-0 size-[20px]" data-node-id="2775:2345" data-name="eye">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgEye} />
              </div>
            </div>
          </div>
          <div className="content-stretch flex items-start justify-end relative shrink-0 w-full" data-node-id="2775:2347" data-name="ForgotRow">
            <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#ff325b] text-[14px] whitespace-nowrap" data-node-id="2775:2348">
              Forgot password?
            </p>
          </div>
        </div>
        <div className="bg-gradient-to-b content-stretch flex from-[var(--stylper-1,#c11e38)] h-[52px] items-center justify-center relative rounded-[14px] shrink-0 to-[#ff627b] w-full" data-node-id="2775:2349" data-name="PrimarySubmit">
          <p className="[word-break:break-word] font-['Inter:Bold'] font-bold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[16px] whitespace-nowrap" data-node-id="2775:2350">
            Sign In
          </p>
        </div>
        <div className="content-stretch flex flex-col gap-[16px] items-center relative shrink-0 w-full" data-node-id="2775:2351" data-name="SocialContainer">
          <div className="content-stretch flex gap-[12px] items-center relative shrink-0 w-full" data-node-id="2775:2352" data-name="DividerRow">
            <div className="flex-[1_0_0] h-0 min-w-px relative" data-node-id="2775:2353" data-name="LineLeft">
              <div className="absolute inset-[-1px_0_0_0]">
                <img alt="" className="block max-w-none size-full" src={imgLineLeft} />
              </div>
            </div>
            <p className="[word-break:break-word] font-['Inter:Medium'] font-medium leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[12px] whitespace-nowrap" data-node-id="2775:2354">
              or sign in with
            </p>
            <div className="flex-[1_0_0] h-0 min-w-px relative" data-node-id="2775:2355" data-name="LineRight">
              <div className="absolute inset-[-1px_0_0_0]">
                <img alt="" className="block max-w-none size-full" src={imgLineLeft} />
              </div>
            </div>
          </div>
          <div className="content-stretch flex gap-[12px] items-start relative shrink-0 w-full" data-node-id="2775:2356" data-name="Buttons">
            <div className="bg-[rgba(26,26,26,0.03)] border border-[rgba(26,26,26,0.07)] border-solid content-stretch flex flex-[1_0_0] gap-[8px] h-[48px] items-center justify-center min-w-px relative rounded-[12px]" data-node-id="2775:2357" data-name="GoogleButton">
              <div className="relative shrink-0 size-[18px]" data-node-id="2775:2358" data-name="circle-x">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgCircleX} />
              </div>
              <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[14px] whitespace-nowrap" data-node-id="2775:2360">
                Google
              </p>
            </div>
            <div className="bg-[rgba(26,26,26,0.03)] border border-[rgba(26,26,26,0.07)] border-solid content-stretch flex flex-[1_0_0] gap-[8px] h-[48px] items-center justify-center min-w-px relative rounded-[12px]" data-node-id="2775:2361" data-name="AppleButton">
              <div className="relative shrink-0 size-[18px]" data-node-id="2775:2362" data-name="apple">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgApple} />
              </div>
              <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[14px] whitespace-nowrap" data-node-id="2775:2364">
                Apple
              </p>
            </div>
          </div>
        </div>
      </div>
      <div className="content-stretch flex flex-col items-center pb-[12px] relative shrink-0 w-full" data-node-id="2775:2365" data-name="Footer">
        <p className="[word-break:break-word] font-['Inter:Regular'] font-normal leading-[0] not-italic relative shrink-0 text-[#898989] text-[14px] whitespace-nowrap" data-node-id="2775:2366">
          <span className="leading-[normal]">{`Don't have an account? `}</span>
          <span className="font-['Inter:Bold'] font-bold leading-[normal] text-[#ff325b]">Sign up</span>
        </p>
      </div>
      <div className="content-stretch flex flex-col h-[34px] items-center justify-end pb-[8px] relative shrink-0 w-full" data-node-id="2775:2367" data-name="HomeIndicatorContainer">
        <div className="bg-[#1a1a1a] h-[5px] opacity-40 relative rounded-[100px] shrink-0 w-[140px]" data-node-id="2775:2368" data-name="HomeIndicator" />
      </div>
    </div>
  );
}
