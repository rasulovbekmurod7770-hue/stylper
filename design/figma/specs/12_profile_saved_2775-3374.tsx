// Figma get_design_context output (verbatim) — node 2775:3374 "Saved" (Figma layer list calls the frame "Profile 4":
// own profile scrolled to the Saved tab, condensed header). File: Z6aHsxkD41lT8lZ8JiBsQv, fetched 2026-10-20.
// Asset URLs expire 2026-10-27; assets live in design/figma/raw/profile_saved. Screenshot: design/figma/screens/12_profile_saved_2775-3374.png (390×844).
// Styles in design: "Stylper soft".
//   3408f.png header_avatar.png  768e5.png card_1_fill.png  78927.png card_1_image.png  5091a/3f26a/8d778.png card_{2,3,4}_image.png
//   b03b4/008c1/895d9/2909d.png avatar_{jason,clara,noah,eve}.png (48×48)
//   92104.svg settings.svg  e639a.svg bookmark.svg  0951f.svg bookmark_2.svg (same glyph, 1px lower)  f77d7.svg bookmark_tag.svg (circle baked in)
//   18295/0841f/3c2fa/f239a/074be.svg tab_{home,search,create,explore,profile_active}.svg   (status icons not downloaded)
const assetPathPrefix = "https://www.figma.com/api/mcp/asset/bc828a84-e981-4947-8089-5911a2e09527";
const imgRectangle43631 = `${assetPathPrefix}/3408f.png`;
const imgImageContainer = `${assetPathPrefix}/768e5.png`;
const imgImageContainer1 = `${assetPathPrefix}/78927.png`;
const imgAvatar = `${assetPathPrefix}/b03b4.png`;
const imgImageContainer2 = `${assetPathPrefix}/5091a.png`;
const imgAvatar1 = `${assetPathPrefix}/008c1.png`;
const imgImageContainer3 = `${assetPathPrefix}/3f26a.png`;
const imgAvatar2 = `${assetPathPrefix}/895d9.png`;
const imgImageContainer4 = `${assetPathPrefix}/8d778.png`;
const imgAvatar3 = `${assetPathPrefix}/2909d.png`;
const imgIosSignal = `${assetPathPrefix}/cc828.svg`;
const imgIosWifiSignal = `${assetPathPrefix}/9dfcf.svg`;
const imgIosBatteryFull = `${assetPathPrefix}/7b0ac.svg`;
const imgIcons = `${assetPathPrefix}/18295.svg`;
const imgIcons1 = `${assetPathPrefix}/0841f.svg`;
const imgTabExplore = `${assetPathPrefix}/3c2fa.svg`;
const imgIcons2 = `${assetPathPrefix}/f239a.svg`;
const imgIcons3 = `${assetPathPrefix}/074be.svg`;
const imgSettings = `${assetPathPrefix}/92104.svg`;
const imgBookmark = `${assetPathPrefix}/e639a.svg`;
const imgBookmark1 = `${assetPathPrefix}/0951f.svg`;
const imgBookmarkTag = `${assetPathPrefix}/f77d7.svg`;

export default function Saved() {
  return (
    <div className="bg-[#fafaf7] overflow-clip relative rounded-[40px] size-full" data-node-id="2775:3374" data-name="Saved">
      <div className="absolute content-stretch flex h-[44px] items-center justify-between left-0 px-[20px] right-0 top-0" data-node-id="2775:3375" data-name="StatusBar">
        <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[14px] whitespace-nowrap" data-node-id="2775:3376">
          9:41
        </p>
        <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-node-id="2775:3377" data-name="Icons">
          <div className="h-[10px] relative shrink-0 w-[18px]" data-node-id="2775:3378" data-name="ios-signal">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosSignal} />
          </div>
          <div className="h-[12px] relative shrink-0 w-[16px]" data-node-id="2775:3380" data-name="ios-wifi-signal">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosWifiSignal} />
          </div>
          <div className="h-[12px] relative shrink-0 w-[24px]" data-node-id="2775:3382" data-name="ios-battery-full">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIosBatteryFull} />
          </div>
        </div>
      </div>
      <div className="absolute h-[88px] left-0 top-0 w-[390px]" data-node-id="2775:3384" />
      <div className="-translate-x-1/2 absolute bg-[#fafaf7] border border-[#424242] border-solid bottom-[22px] content-stretch drop-shadow-[0px_12px_12px_rgba(0,0,0,0.04)] flex gap-[16px] items-center justify-center left-[calc(50%-5px)] p-[8px] rounded-[100px]" data-node-id="2775:3385" data-name="bottom-nav-container">
        <div className="content-stretch flex items-center justify-center p-[8px] relative rounded-[100px] shrink-0" data-node-id="2775:3386" data-name="tab-home">
          <div className="overflow-clip relative shrink-0 size-[24px]" data-node-id="2775:3387" data-name="Icons">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIcons} />
          </div>
        </div>
        <div className="content-stretch flex items-center justify-center p-[8px] relative rounded-[100px] shrink-0" data-node-id="2775:3388" data-name="tab-search">
          <div className="overflow-clip relative shrink-0 size-[24px]" data-node-id="2775:3389" data-name="Icons">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIcons1} />
          </div>
        </div>
        <div className="relative shrink-0 size-[32px]" data-node-id="2775:3390" data-name="tab-explore">
          <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgTabExplore} />
        </div>
        <div className="content-stretch flex items-center justify-center p-[8px] relative rounded-[100px] shrink-0" data-node-id="2775:3392" data-name="tab-explore">
          <div className="overflow-clip relative shrink-0 size-[24px]" data-node-id="2775:3393" data-name="Icons">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIcons2} />
          </div>
        </div>
        <div className="bg-gradient-to-b content-stretch flex from-[var(--stylper-1,#c11e38)] items-center justify-center p-[8px] relative rounded-[100px] shrink-0 to-[#ff627b]" data-node-id="2775:3394" data-name="tab-you">
          <div className="overflow-clip relative shrink-0 size-[24px]" data-node-id="2775:3395" data-name="Icons">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIcons3} />
          </div>
        </div>
      </div>
      <div className="absolute bg-[#1a1a1a] h-[5px] left-[125px] opacity-40 rounded-[100px] top-[831px] w-[140px]" data-node-id="2775:3396" data-name="HomeIndicator" />
      <div className="absolute content-stretch flex gap-[16px] items-center left-0 px-[20px] py-[12px] top-[57px] w-[390px]" data-node-id="2775:3397" data-name="condensed-header">
        <div className="relative rounded-[34.224px] shrink-0 size-[54px]" data-node-id="2775:3398">
          <div aria-hidden className="absolute inset-0 pointer-events-none rounded-[34.224px]">
            <div className="absolute bg-[#d9d9d9] inset-0 rounded-[34.224px]" />
            <img alt="" className="absolute max-w-none object-cover rounded-[34.224px] size-full" src={imgRectangle43631} />
          </div>
        </div>
        <div className="[word-break:break-word] content-stretch flex flex-[1_0_0] flex-col gap-[2px] items-start leading-[normal] min-w-px not-italic relative whitespace-nowrap" data-node-id="2775:3399" data-name="meta">
          <p className="font-['Poppins:SemiBold'] relative shrink-0 text-[#1a1a1a] text-[16px]" data-node-id="2775:3400">
            John. B
          </p>
          <p className="font-['Inter:Regular'] font-normal relative shrink-0 text-[#807a87] text-[12px]" data-node-id="2775:3401">
            @john
          </p>
        </div>
        <div className="content-stretch flex items-start relative shrink-0" data-node-id="2775:3402" data-name="settings">
          <div className="bg-[#f2f2f0] border border-[rgba(26,26,26,0.07)] border-solid content-stretch flex items-center justify-center relative rounded-[18px] shrink-0 size-[36px]" data-node-id="2775:3403" data-name="btn">
            <div className="relative shrink-0 size-[18px]" data-node-id="2775:3404" data-name="settings">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgSettings} />
            </div>
          </div>
        </div>
      </div>
      <div className="absolute border-[rgba(26,26,26,0.07)] border-b border-solid content-stretch flex gap-[16px] h-[44px] items-center left-0 px-[20px] top-[137px] w-[390px]" data-node-id="2775:3406" data-name="tab-header">
        <div className="content-stretch flex flex-[1_0_0] flex-col h-full items-center justify-center min-w-px relative" data-node-id="2775:3407" data-name="tab-Posts">
          <p className="[word-break:break-word] font-['Poppins:Medium'] leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[14px] whitespace-nowrap" data-node-id="2775:3408">
            Posts
          </p>
        </div>
        <div className="content-stretch flex flex-[1_0_0] flex-col gap-[8px] h-full items-center justify-center min-w-px relative" data-node-id="2775:3409" data-name="tab-Saved">
          <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[14px] whitespace-nowrap" data-node-id="2775:3410">
            Saved
          </p>
          <div className="bg-[#ff627b] h-[2px] relative rounded-[1px] shrink-0 w-[40px]" data-node-id="2775:3411" data-name="active-bar" />
        </div>
        <div className="content-stretch flex flex-[1_0_0] flex-col h-full items-center justify-center min-w-px relative" data-node-id="2775:3412" data-name="tab-Style Boards">
          <p className="[word-break:break-word] font-['Poppins:Medium'] leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[14px] whitespace-nowrap" data-node-id="2775:3413">
            Style Boards
          </p>
        </div>
      </div>
      <div className="absolute content-stretch flex gap-[16px] items-start left-0 pb-[120px] pt-[16px] px-[20px] top-[189px] w-[390px]" data-node-id="2775:3414" data-name="grid">
        <div className="content-stretch flex flex-[1_0_0] flex-col gap-[16px] items-start min-w-px relative" data-node-id="2775:3415" data-name="col-1">
          <div className="bg-[#f2f2f0] border border-[rgba(26,26,26,0.07)] border-solid content-stretch flex flex-col items-start overflow-clip relative rounded-[24px] shrink-0 w-full" data-node-id="2775:3416" data-name="saved-card">
            <div className="h-[190px] relative shrink-0 w-full" data-node-id="2775:3417" data-name="image-container">
              <div aria-hidden className="absolute inset-0 pointer-events-none">
                <img alt="" className="absolute max-w-none object-cover size-full" src={imgImageContainer} />
                <div className="absolute inset-0 overflow-hidden">
                  <img alt="" className="absolute h-[151.79%] left-[0.07%] max-w-none top-[-0.04%] w-full" src={imgImageContainer1} />
                </div>
              </div>
              <div className="absolute bg-[rgba(0,0,0,0.5)] content-stretch flex items-center justify-center right-[12px] rounded-[16px] size-[32px] top-[12px]" data-node-id="2775:3419" data-name="bookmark-tag">
                <div className="relative shrink-0 size-[14px]" data-node-id="2775:3420" data-name="bookmark">
                  <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgBookmark} />
                </div>
              </div>
            </div>
            <div className="content-stretch flex gap-[8px] items-center p-[12px] relative shrink-0 w-full" data-node-id="2775:3422" data-name="card-info">
              <div className="relative shrink-0 size-[24px]" data-node-id="2775:3423" data-name="avatar">
                <img alt="" className="absolute block inset-0 max-w-none size-full" height="24" src={imgAvatar} width="24" />
              </div>
              <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Regular'] font-normal leading-[normal] min-w-px not-italic overflow-hidden relative text-[#1a1a1a] text-[12px] text-ellipsis whitespace-nowrap" data-node-id="2775:3424">
                @jason
              </p>
            </div>
          </div>
          <div className="bg-[#f2f2f0] border border-[rgba(26,26,26,0.07)] border-solid content-stretch flex flex-col items-start overflow-clip relative rounded-[24px] shrink-0 w-full" data-node-id="2775:3425" data-name="saved-card">
            <div className="h-[160px] relative shrink-0 w-full" data-node-id="2775:3426" data-name="image-container">
              <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none size-full" src={imgImageContainer2} />
              <div className="absolute bg-[rgba(0,0,0,0.5)] content-stretch flex items-center justify-center right-[12px] rounded-[16px] size-[32px] top-[12px]" data-node-id="2775:3428" data-name="bookmark-tag">
                <div className="relative shrink-0 size-[14px]" data-node-id="2775:3429" data-name="bookmark">
                  <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgBookmark1} />
                </div>
              </div>
            </div>
            <div className="content-stretch flex gap-[8px] items-center p-[12px] relative shrink-0 w-full" data-node-id="2775:3431" data-name="card-info">
              <div className="relative shrink-0 size-[24px]" data-node-id="2775:3432" data-name="avatar">
                <img alt="" className="absolute block inset-0 max-w-none size-full" height="24" src={imgAvatar1} width="24" />
              </div>
              <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Regular'] font-normal leading-[normal] min-w-px not-italic overflow-hidden relative text-[#1a1a1a] text-[12px] text-ellipsis whitespace-nowrap" data-node-id="2775:3433">
                @clara_v
              </p>
            </div>
          </div>
        </div>
        <div className="content-stretch flex flex-[1_0_0] flex-col gap-[16px] items-start min-w-px relative" data-node-id="2775:3434" data-name="col-2">
          <div className="bg-[#f2f2f0] border border-[rgba(26,26,26,0.07)] border-solid content-stretch flex flex-col items-start overflow-clip relative rounded-[24px] shrink-0 w-full" data-node-id="2775:3435" data-name="saved-card">
            <div className="h-[150px] relative shrink-0 w-full" data-node-id="2775:3436" data-name="image-container">
              <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none size-full" src={imgImageContainer3} />
              <div className="absolute bg-[rgba(0,0,0,0.5)] content-stretch flex items-center justify-center right-[12px] rounded-[16px] size-[32px] top-[12px]" data-node-id="2775:3438" data-name="bookmark-tag">
                <div className="relative shrink-0 size-[14px]" data-node-id="2775:3439" data-name="bookmark">
                  <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgBookmark} />
                </div>
              </div>
            </div>
            <div className="content-stretch flex gap-[8px] items-center p-[12px] relative shrink-0 w-full" data-node-id="2775:3441" data-name="card-info">
              <div className="relative shrink-0 size-[24px]" data-node-id="2775:3442" data-name="avatar">
                <img alt="" className="absolute block inset-0 max-w-none size-full" height="24" src={imgAvatar2} width="24" />
              </div>
              <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Regular'] font-normal leading-[normal] min-w-px not-italic overflow-hidden relative text-[#1a1a1a] text-[12px] text-ellipsis whitespace-nowrap" data-node-id="2775:3443">
                @noah_st
              </p>
            </div>
          </div>
          <div className="bg-[#f2f2f0] border border-[rgba(26,26,26,0.07)] border-solid content-stretch flex flex-col items-start overflow-clip relative rounded-[24px] shrink-0 w-full" data-node-id="2775:3444" data-name="saved-card">
            <div className="h-[200px] relative shrink-0 w-full" data-node-id="2775:3445" data-name="image-container">
              <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none size-full" src={imgImageContainer4} />
              <div className="absolute right-[12px] size-[32px] top-[12px]" data-node-id="2775:3447" data-name="bookmark-tag">
                <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgBookmarkTag} />
              </div>
            </div>
            <div className="content-stretch flex gap-[8px] items-center p-[12px] relative shrink-0 w-full" data-node-id="2775:3450" data-name="card-info">
              <div className="relative shrink-0 size-[24px]" data-node-id="2775:3451" data-name="avatar">
                <img alt="" className="absolute block inset-0 max-w-none size-full" height="24" src={imgAvatar3} width="24" />
              </div>
              <p className="[word-break:break-word] flex-[1_0_0] font-['Inter:Regular'] font-normal leading-[normal] min-w-px not-italic overflow-hidden relative text-[#1a1a1a] text-[12px] text-ellipsis whitespace-nowrap" data-node-id="2775:3452">
                @eve_dress
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
